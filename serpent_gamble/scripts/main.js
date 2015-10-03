// web3.setProvider(new web3.providers.HttpProvider('http://localhost:30303'));
var app = angular.module('serpent_gamble', []);

// Quick utility methods to grab specific HTML elements
var el = function(x) { return document.getElementById(x); }
var qs = function(x) { return document.querySelectorAll(x); }

// Convert integer to address
// TODO: put a method for this into web3.js proper
var tt160 = web3.toBigNumber(2).pow(160);
var intToAddress = function(x) {
    var y = web3.toHex(x.mod(tt160));
    if (y.length < 42) {
        y = "0x" + Array(41 - y.length).join("0") + y.substring(2);
    }
    return y;
}


// Main controller
function SerpentGambleCtrl($scope, $rootScope, $http) {
    var eth = web3.eth;
    web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));
    window.mainScope = $scope;
    // Model representation for the current bet and user
    $scope.bet = {
        amount: 0.001,
        win_prob: 0.2
    }
    // Fee charged by the gambling contract
    $scope.feePercent = "...";
    // The user's accounts
    $scope.accounts = web3.eth.accounts;
    // The user's selected account to bet
    $scope.myAccount = web3.eth.accounts[0];
    // Make a web3 object for our contract
    $scope.ABI = window.accounts.gamble.abi
    $scope.CONTRACT_ADDRESS = window.accounts.gamble.address
    $scope.ADMIN = window.accounts.admin.address
    $scope.contract = web3.eth.contract($scope.ABI).at($scope.CONTRACT_ADDRESS)
    // Boolean variable showing whether or not the user has admin rihts
    $scope.amAdmin = (eth.accounts.indexOf($scope.ADMIN) >= 0)
    // Model object for showing the current bets
    $scope.bets = [];
    // And previous bets
    $scope.prevbets = [];
    // Try to send a transaction, and display dialog for success or failure
    $scope.tryToSend = function(fun, successMsg, longSuccessMsg) {
        try {
            var h = fun();
            $rootScope.addTransaction(h, successMsg, longSuccessMsg);
        }
        catch (e) {
            console.log("Error", e);
            $rootScope.dialogMessage = {
                title: "Could not send transaction",
                body: "<ul><li>Do you have the account you are trying to use unlocked?</li><li>Do you have enough ether?</li>"
            }
        }
    }
    // Update the list of current bets
    $scope.get_bets = function() {
        var betCount = $scope.contract.get_num_bets();
        var bets = [];
        for (var i = 0; i < betCount; i++) {
            var o = $scope.contract.get_bet(i);
            bets.push({
                bettor: intToAddress(o[0]),
                potentialWinnings: parseFloat(web3.fromWei(o[1], 'ether')),
                prob: o[2] * 0.001,
            })
        }
        return bets;
    }
    $scope.bets = $scope.get_bets();
    // Update the list of recent bets
    $scope.prevbets = [];
    $scope.recent_newseeds = new filtered_list($scope.contract.NewSeed({},{address: $scope.CONTRACT_ADDRESS, fromBlock: eth.blockNumber - 10000}), function() {
        $scope.get_prevbets();
    })
    $scope.get_prevbets = function() {
        console.log('getting recent wins and losses', new Date().getTime());
        if ($scope.recent_newseeds.logs.length == 0) {
            console.log('Could not find recently submitted seed');
            $scope.prevbets = [];
            return;
        }
        // Get the latest instance of a NewSeed event
        var lastNewSeed = $scope.recent_newseeds.logs[$scope.recent_newseeds.logs.length - 1];
        var prevbets = [];
        var params = {address: $scope.CONTRACT_ADDRESS, fromBlock: lastNewSeed.blockNumber, toBlock: lastNewSeed.blockNumber};
        // Get the win logs from that block
        $scope.contract.Win({},params).get(function(err, wins) {
            console.log('fetched recent wins', wins);
            // Get the loss logs from that block
            $scope.contract.Loss({},params).get(function(err, losses) {
                console.log('fetched recent losses', wins);
                for (var i = 0; i < wins.length; i++) {
                    prevbets.push({
                        bettor: wins[i].args.bettor,
                        potentialWinnings: parseFloat(web3.fromWei(wins[i].args.potentialWinnings, 'ether')),
                        prob: wins[i].args.prob_milli * 0.001,
                        result: 'win',
                        blockNumber: wins[i].blockNumber
                    });
                }
                for (var i = 0; i < losses.length; i++) {
                    prevbets.push({
                        bettor: losses[i].args.bettor,
                        potentialWinnings: parseFloat(web3.fromWei(losses[i].args.potentialWinnings, 'ether')),
                        prob: losses[i].args.prob_milli * 0.001,
                        result: 'loss',
                        blockNumber: losses[i].blockNumber
                    });
                }
                // Sort wins and losses by block number
                $scope.prevbets = prevbets.sort(function(x, y) { x.blockNumber > y.blockNumber });
            });
        });
    }
    // Show current seedhash
    $scope.seedhash = $scope.contract.get_curseed();
    // Available funds in the contract in wei
    $scope.available_funds = $scope.contract.get_available_funds();
    // ... and in eth (for UI purposes)
    $scope.available_funds_in_eth = parseFloat(web3.fromWei($scope.available_funds, 'ether'));
    // Contract's fee as a percentage
    $scope.feePercent = parseInt($scope.contract.get_fee_millis()) * 0.1;
    // Administration status
    $scope.administration_status = parseInt($scope.contract.get_administration_status());
    // When a new block comes in, re-evaluate the list of bets
    var filter = web3.eth.filter('latest');
    // Update some variables every time a new block comes in
    var onBlock = function(error, result) {
        console.log('main filter');
        $scope.bets = $scope.get_bets();
        $scope.get_prevbets();
        $scope.contract.get_curseed({}, function(err, res) {
            $scope.seedhash = res;
            $scope.$apply();
        });
        $scope.contract.get_available_funds({}, function(err, res) {
            $scope.available_funds = res;
            $scope.available_funds_in_eth = parseFloat(web3.fromWei($scope.available_funds, 'ether'));
            $scope.checkifWeCanBet();
            $scope.$apply();
        });
        $scope.contract.get_administration_status({}, function(err, res) {
            $scope.administration_status = parseInt(res);
            $scope.$apply();
        });
        $scope.contract.get_fee_millis({}, function(err, res) {
            $scope.feePercent = parseInt(res) * 0.1;
        });
    };
    filter.watch(onBlock);
    onBlock();
    // Check if we can bet
    $scope.cannot_bet = true;
    $scope.cannot_bet_error_message = "";
    $scope.checkifWeCanBet = function() {
        eth.getBalance($scope.myAccount, function(err, res) {
            var winProbMillis = Math.floor(parseFloat($scope.bet.win_prob) * 1000);
            if (web3.toBigNumber(web3.toWei($scope.bet.amount, 'ether')).gt(res)) {
                $scope.cannot_bet = true;
                $scope.cannot_bet_error_message = "You do not have enough funds"
            }
            else if (winProbMillis < 10 || winProbMillis >= 1000) {
                $scope.cannot_bet = true;
                $scope.cannot_bet_error_message = "Invalid winning probability (0.01 <= p <= 0.999 required)"
            }    
            else if ($scope.administration_status > 0) {
                $scope.cannot_bet = true;
                $scope.cannot_bet_error_message = "Administrator is currently submitting their hash"
            }
            else {
                var winnings = web3.toBigNumber(web3.toWei($scope.bet.amount, 'ether')).mul(1000).div(winProbMillis);
                $scope.cannot_bet = winnings.gt($scope.available_funds);
                if ($scope.cannot_bet)
                    $scope.cannot_bet_error_message = "Contract does not have enough funds"
            }
            if (!$scope.$$phase) $scope.$apply();
        });
    }
    $scope.watch('bet', $scope.checkifWeCanBet, true);
    setInterval($scope.checkifWeCanBet, 250);
    $scope.checkifWeCanBet();
    // Make a new bet
    $scope.mkBet = function() {
        $scope.tryToSend(function() {
            return $scope.contract.bet(Math.floor(Math.random() * 100000000),
                                       Math.floor(parseFloat($scope.bet.win_prob) * 1000),
                                       {from: $scope.myAccount,
                                        value: web3.toWei($scope.bet.amount, 'ether'),
                                        gas: 500000});
        }, "Betting");
    }
    // Administrator seed data
    $scope.admin = {
        oldSeed: null,
        newSeed: null,
        lastSubmittednewSeed: null,
        newSeedhash: null,
        setSeedhashDisabled: true,
        fee: 0,
        setFeeDisabled: true,
        withdrawalAmount: 0,
        withdrawDisabled: true,
        cannotSetFeeErrorMessage: "",
        cannotWithdrawErrorMessage: "",
        cannotSetSeedhashErrorMessage: "",
    }
    $scope.unlockForAdministration = function() {
        $scope.tryToSend(function() {
            return $scope.contract.unlock_for_administration({from: $scope.ADMIN, gas: 500000});
        }, "Unlocking administrative status");
    }

    // Generate a new seed
    $scope.genSeed = function() {
        // TODO: make the RNG actually good
        $scope.admin.newSeed = '0x' + web3.sha3(Math.random() + " " + new Date().getTime() + " " + Math.random());
    }

    // Check if all inputs are correct for us to be able to update the seed
    $scope.checkIfWeCanChangeSeed = function() {
        if ($scope.admin.newSeed) {
            var s = $scope.admin.newSeed || '';
            var os = $scope.admin.oldSeed || '';
            if (s.substr(0, 2) != '0x')
                s = '0x' + s;
            if (os.substr(0, 2) != '0x')
                os = '0x' + os;
            if (s.length != 66) {
                $scope.admin.newSeedhash = null;
                $scope.admin.setSeedhashDisabled = true;
                $scope.admin.cannotSetSeedhashErrorMessage = "Seedhash must be 32 bytes long and in hexadecimal format";
            }
            else if (s == os) {
                $scope.admin.newSeedhash = null;
                $scope.admin.setSeedhashDisabled = true;
                $scope.admin.cannotSetSeedhashErrorMessage = "Please generate a new seed that is not equal to your old seed!";
            }
            else if (os.length != 66 && $scope.seedhash != '0x0000000000000000000000000000000000000000000000000000000000000000') {
                $scope.admin.newSeedhash = '0x' + sha3Hex(""+$scope.admin.newSeed, true);
                $scope.admin.setSeedhashDisabled = true;
                $scope.admin.cannotSetSeedhashErrorMessage = "Provided old seed must be 32 bytes long and in hexadecimal format";
            }
            else if ($scope.seedhash != '0x0000000000000000000000000000000000000000000000000000000000000000' && '0x'+sha3Hex(""+($scope.admin.oldSeed || "")) != $scope.seedhash) {
                $scope.admin.newSeedhash = '0x' + sha3Hex(""+$scope.admin.newSeed, true);
                $scope.admin.setSeedhashDisabled = true;
                $scope.admin.cannotSetSeedhashErrorMessage = "Provided old seed does not match hash in contract"
            }
            else {
                $scope.admin.newSeedhash = '0x' + sha3Hex(""+$scope.admin.newSeed, true);
                $scope.admin.setSeedhashDisabled = false;
            }
        }
        else {
            $scope.admin.setSeedhashDisabled = true;
            $scope.admin.cannotSetSeedhashErrorMessage = "Please enter a new seed or create one with \"Generate Seed\"";
        }
    };

    // Check if we can set the fee to the desired value
    $scope.checkIfWeCanSetFee = function() {
        if (parseFloat($scope.admin.fee) < 0) {
            $scope.admin.setFeeDisabled = true;
            $scope.admin.cannotSetFeeErrorMessage = "Fee cannot be below zero!"
        }
        else if (parseFloat($scope.admin.fee) > 0.999) {
            $scope.admin.setFeeDisabled = true;
            $scope.admin.cannotSetFeeErrorMessage = "Fee cannot be above 99.9 percent!"
        }
        else if (parseFloat($scope.admin.fee) >= 0 && parseFloat($scope.admin.fee) <= 0.999) {
            $scope.admin.setFeeDisabled = false;
        }
        else {
            $scope.admin.setFeeDisabled = true;
            $scope.admin.cannotSetFeeErrorMessage = "Bad input for fee"
        }
    };

    // Check if we can withdraw the desired amount
    $scope.checkIfWeCanWithdraw = function() {
        $scope.admin.withdrawDisabled = ($scope.available_funds_in_eth < parseFloat($scope.admin.withdrawalAmount));
        $scope.admin.cannotWithdrawErrorMessage = "Bad withdrawal amount"
    }
    setInterval($scope.checkIfWeCanChangeSeed, 250);
    setInterval($scope.checkIfWeCanWithdraw, 250);
    setInterval($scope.checkIfWeCanSetFee, 250);

    // Change seed
    $scope.changeSeed = function() {
        $scope.tryToSend(function() {
            return $scope.contract.set_curseed($scope.admin.oldSeed,
                                                '0x' + sha3Hex($scope.admin.newSeed, true),
                                                {from: $scope.ADMIN, gas: 1500000});
        }, "Changing seed", "The new seed that you have set is: " + $scope.admin.newSeed + ". Please make sure to store this seed; within 48 hours, you must come back to this tab and input the seed into the \"Old seed\" textbox in order to resolve all bets and generate a new seed");
    }

    // Change fee
    $scope.setFee = function() {
        $scope.tryToSend(function() {
            return $scope.contract.set_fee_millis(Math.floor(parseFloat($scope.admin.fee) * 1000),
                                                  {from: $scope.ADMIN, gas: 1000000});
        }, "Changing the fee");
    }

    // Withdraw
    $scope.withdraw = function() {
        $scope.tryToSend(function() {
            return $scope.contract.withdraw(web3.toWei($scope.admin.withdrawalAmount, 'ether'),
                                            {from: $scope.ADMIN, gas: 1000000});
        }, "Withdrawing");
    }
}
