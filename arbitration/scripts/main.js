// web3.setProvider(new web3.providers.HttpProvider('http://localhost:30303'));
var app = angular.module('arbitration', []);

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

// Check an address is valid and if so return it in normalized form.
// Otherwise return null.
var normalizeAddress = function(x) {
    if (x.length == 40) x = '0x' + x;
    if (x.length != 42) return null;
    for (var i = 2; i < 42; i++) {
        if ("0123456789abcdef".indexOf(x[i]) == -1) return null;
    }
    return x;
}


// Main controller
function ArbitrationCtrl($scope, $rootScope, $http) {
    var eth = web3.eth;
    web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));
    window.mainScope = $scope;
    // Model representation for the current escrow
    $scope.escrow = {
        otherAddress: '',
        arbiters: [],
        newArbiter: '',
        newArbiterFromSelection: '',
        newArbiterFromSelectionDescription: '',
        value: 15,
        fee: 5,
        description: ""
    }
    $scope.arbiterFeePaid = {};
    // The user's accounts
    $scope.accounts = web3.eth.accounts;
    // The user's selected account to bet
    $scope.myAccount = web3.eth.accounts[0];
    // Make web3 objects for our contracts
    $scope.ARBITRATION_ABI = window.accounts.arbitration.abi
    $scope.ARBITRATION_CONTRACT_ADDRESS = window.accounts.arbitration.address
    $scope.arbitration_contract = web3.eth.contract($scope.ARBITRATION_ABI).at($scope.ARBITRATION_CONTRACT_ADDRESS)
    $scope.ARBREG_ABI = window.accounts.arbiter_reg.abi
    $scope.ARBREG_CONTRACT_ADDRESS = window.accounts.arbiter_reg.address
    $scope.arbreg_contract = web3.eth.contract($scope.ARBREG_ABI).at($scope.ARBREG_CONTRACT_ADDRESS)
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
    // Model object representing list of current arbiters
    $scope.arbiters = []
    // Update the list of current bets
    $scope.get_arbiters = function() {
        var add_arbiters = function(existingList, cb) {
            $scope.arbreg_contract.get_addresses(existingList.length, function(err, res) {
                if (err) return;
                else if (res.length < 50) cb(null, existingList.concat(res));
                else add_arbiters(existingList.concat(res), cb);
            });
        }
        add_arbiters([], function(err, res) {
            if (err) return;
            $scope.arbiters = res.sort(function(x, y) { $scope.arbiterFeePaid[x] < $scope.arbiterFeePaid[y] });
        });
    }
    // Update the fees paid by each arbiter
    $scope.update_fees_paid_map = function() {
        $scope.arbiters.map(function(a) {
            $scope.arbreg_contract.get_tot_fee(a, function(err, res) {
                if (err) return;
                $scope.arbiterFeePaid[a] = parseFloat(web3.fromWei(res, 'ether'));
            });
        });
    }
    $scope.get_arbiters();
    $scope.update_fees_paid_map();
    web3.eth.filter('latest').watch(function(err, res) {
        console.log('getting arbiters from directory');
        $scope.get_arbiters();
        $scope.update_fees_paid_map();
        console.log('gotten arbiters from directory');
    });
    // Helper functions to add and remove arbiters
    $scope.removeArbiter = function(a) {
        var i = 0;
        while (i < $scope.escrow.arbiters.length) {
            if ($scope.escrow.arbiters[i] == a) { $scope.escrow.arbiters.splice(i, 1); return; }
            else i += 1;
        }
    }
    $scope.addArbiter = function() {
        var addr = normalizeAddress($scope.escrow.newArbiter);
        if (addr) {
            $scope.escrow.arbiters.push(addr);
            $scope.escrow.newArbiter = '';
        }
    }
    $scope.addArbiterFromSelection = function() {
        var addr = normalizeAddress($scope.escrow.newArbiterFromSelection);
        if (addr) {
            $scope.escrow.arbiters.push(addr);
            $scope.escrow.newArbiterFromSelection = '';
        }
    }
    // Update the description shown for the arbiter selected via the ng-select
    // object
    var oldNewArbiterFromSelection = "";
    setInterval(function() {
        if (oldNewArbiterFromSelection != $scope.escrow.newArbiterFromSelection) {
            oldNewArbiterFromSelection = $scope.escrow.newArbiterFromSelection;
            $scope.arbreg_contract.get_description($scope.escrow.newArbiterFromSelection, function(err, res) {
                if (err) return;
                $scope.escrow.newArbiterFromSelectionDescription = web3.toUtf8(res);
            });
        }
    }, 250);
    // Check if we can send
    setInterval(function() {
        if (!parseFloat($scope.escrow.value)) {
            $scope.cannot_create_escrow = true;
            $scope.cannot_create_escrow_error_message = "Invalid escrow value";
        }
        else if (!parseFloat($scope.escrow.fee)) {
            $scope.cannot_create_escrow = true;
            $scope.cannot_create_escrow_error_message = "Invalid escrow fee";
        }
        else if ($scope.escrow.arbiters.length == 0) {
            $scope.cannot_create_escrow = true;
            $scope.cannot_create_escrow_error_message = "Must have at least one arbiter!";
        }
        else if ($scope.escrow.arbiters.length > 30) {
            $scope.cannot_create_escrow = true;
            $scope.cannot_create_escrow_error_message = "Maximum 30 arbiters";
        }
        else if ($scope.escrow.description.length > 288) {
            $scope.cannot_create_escrow = true;
            $scope.cannot_create_escrow_error_message = "Description too long (max 288 chars)";
        }
        else if (!normalizeAddress($scope.escrow.otherAddress)) {
            $scope.cannot_create_escrow = true;
            $scope.cannot_create_escrow_error_message = "Counterparty's address invalid";
        }
        else {
            eth.getBalance($scope.myAccount, function(err, res) {
                var valueInWei = web3.toBigNumber(web3.toWei($scope.escrow.value, 'ether'));
                var feeInWei = web3.toBigNumber(web3.toWei($scope.escrow.fee, 'ether'));
                if (res.lt(valueInWei.add(feeInWei))) {
                    $scope.cannot_create_escrow = true;
                    $scope.cannot_create_escrow_error_message = "Not enough funds to pay value+fee";
                }
                else {
                    $scope.cannot_create_escrow = false;
                    $scope.cannot_create_escrow_error_message = "Not enough funds";
                }
            });
        }
        if (!$scope.$$phase) $scope.$apply();
    }, 250);
    $scope.cannot_create_escrow = true;
    $scope.cannot_create_escrow_error_message = "";
    // Make a new escrow
    $scope.createEscrow = function() {
        var valueInWei = web3.toBigNumber(web3.toWei($scope.escrow.value, 'ether'));
        var feeInWei = web3.toBigNumber(web3.toWei($scope.escrow.fee, 'ether'));
        $scope.tryToSend(function() {
            return $scope.arbitration_contract.mk_contract($scope.myAccount,
                                                           normalizeAddress($scope.escrow.otherAddress),
                                                           $scope.escrow.arbiters,
                                                           feeInWei,
                                                           $scope.escrow.description,
                                                           {from: $scope.myAccount,
                                                            value: valueInWei.add(feeInWei),
                                                            gas: 500000 + 30000 * $scope.escrow.arbiters.length});
        }, "Creating escrow");
    }
    $scope.listingFee = 0.001;
    $scope.listingDescription = "";
    setInterval(function() {
        if ($scope.listingFee < 0.002) {
            $scope.cannot_register = true;
            $scope.cannot_register_error_message = "Fee too low!";
        }
        $scope.cannot_register = false;
    }, 250);
    $scope.cannot_register = true;
    $scope.cannot_register_error_message = "";
    // Register
    $scope.registerArbiter = function() {
        $scope.tryToSend(function() {
            return $scope.arbreg_contract.register({from: $scope.myAccount,
                                                    value: web3.toWei($scope.listingFee, 'ether'),
                                                    gas: 500000});
        }, "Registering and paying fee");
    }
    var checkIfCanSetArbiterDescription = function(err, res) {
        $scope.arbreg_contract.get_tot_fee($scope.myAccount, function(err, res) {
            if (err) return;
            if (web3.toDecimal(res) == "0") {
                $scope.cannot_set_description = true;
                $scope.cannot_set_description_error_message = "Account not yet registered!";
            }
            else if (res.lt(web3.toBigNumber(web3.toWei(1, "finney")))) {
                $scope.cannot_set_description = true;
                $scope.cannot_set_description_error_message = "Need to top up your fee!";
            }
            else $scope.cannot_set_description = false;
        });
        $scope.arbreg_contract.get_description($scope.myAccount, function(err, res) {
            if (err) return;
            $scope.currentArbiterDescription = web3.toUtf8(res);
        })
    }
    web3.eth.filter('latest').watch(checkIfCanSetArbiterDescription);
    checkIfCanSetArbiterDescription();
    $scope.cannot_set_description = true;
    $scope.cannot_set_description_error_message = "";
    // Set description
    $scope.setArbiterDescription = function() {
        $scope.tryToSend(function() {
            return $scope.arbreg_contract.set_description($scope.listingDescription,
                                                          {from: $scope.myAccount,
                                                           gas: 500000});
        }, "Setting description");
    }
    $scope.escrows = [];
    $scope.processEscrowList = function() {
        console.log('processing escrow list');
        var o = {};
        $scope.arbNL1.logs.map(function(x) { o[x.transactionHash] = x; });
        $scope.arbNL2.logs.map(function(x) { o[x.transactionHash] = x; });
        $scope.arbNL3.logs.map(function(x) { o[x.transactionHash] = x; });
        var totList = [];
        Object.keys(o).map(function(k) { totList.push(o[k]); });
        $scope.numGathering = totList.length;
        $scope.totGathered = 0;
        $scope.gathering = [];
        for (var i = 0; i < $scope.numGathering; i++) {
            (function(log) {
                $scope.arbitration_contract.get_contract_value(log.args.id, function(err, res) {
                    if (err) return;
                    $scope.arbitration_contract.get_contract_description(log.args.id, function(err, res2) {
                        if (err) return;
                        $scope.arbitration_contract.get_contract_arbiterFee(log.args.id, function(err, res3) {
                            if (err) return;
                            var type = (log.args.arbiter == $scope.myAccount)    ? 1
                                :      (log.args.recipientA == $scope.myAccount) ? 2
                                :      (log.args.recipientB == $scope.myAccount) ? 3
                                : 4;
                            if (type < 4 && parseFloat(web3.toDecimal(web3.fromWei(res, 'ether'))) > 0) {
                                $scope.gathering.push({
                                    value: parseFloat(web3.fromWei(res, 'ether')),
                                    description: web3.toUtf8(res2),
                                    fee: parseFloat(web3.fromWei(res3, 'ether')),
                                    id: log.args.id,
                                    type: type
                                });
                            }
                            $scope.totGathered += 1;
                            if ($scope.totGathered == $scope.numGathering) {
                                $scope.escrows = $scope.gathering;
                                console.log('created escrow list', $scope.escrows);
                            }
                        });
                    });
                });
            })(totList[i]);
        }
    };
    $scope.myOldAccount = null;
    $scope.resetEscrowFilters = function() {
        if ($scope.myAccount == $scope.myOldAccount) return;
        $scope.myOldAccount = $scope.myAccount;
        console.log('resetting escrow filters');
        [$scope.arbNL1, $scope.arbNL2, $scope.arbNL3].map(function(x) { if (x) x.shutdown() });
        var gathered = 0;
        var cb = function() {
            gathered += 1;
            if (gathered == 3) { console.log('pl'); $scope.processEscrowList(); }
        }
        var arbNotifyFilter = $scope.arbitration_contract.ArbiterNotification({address:$scope.myAccount},{fromBlock: eth.blockNumber - 30000});
        $scope.arbNL1 = new filtered_list(arbNotifyFilter, cb);
        var arbNotifyFilter2 = $scope.arbitration_contract.NewContract({recipientA: $scope.myAccount}, {fromBlock: eth.blockNumber - 30000});
        $scope.arbNL2 = new filtered_list(arbNotifyFilter2, cb);
        var arbNotifyFilter3 = $scope.arbitration_contract.NewContract({recipientB: $scope.myAccount}, {fromBlock: eth.blockNumber - 30000});
        $scope.arbNL3 = new filtered_list(arbNotifyFilter3, cb);
        $scope.myAccount = newVal;
    }
    eth.filter('latest', $scope.processEscrowList);
    setInterval($scope.resetEscrowFilters, 250);
    // Vote on a particular escrow
    $scope.vote = function(id, value) {
        $scope.tryToSend(function() {
            return $scope.arbitration_contract.vote(id, value,
                                                    {from: $scope.myAccount,
                                                     gas: 1000000});
        }, "Creating escrow");
    }
}
