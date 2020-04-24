// web3.setProvider(new web3.providers.HttpProvider('http://localhost:30303'));
var app = angular.module('listlogs', []);

// Quick utility methods to grab specific HTML elements
var el = function(x) { return document.getElementById(x); }
var qs = function(x) { return document.querySelectorAll(x); }

// Main controller
function ListLogsCtrl($scope, $rootScope, $http) {
    var eth = web3.eth;
    var mainContract = eth.contract(window.accounts.main.abi).at(window.accounts.main.address);
    $scope.mc = mainContract;
    $scope.boundary = 419998;
    $scope.latestBlock = 0;
    web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));
    $scope.logFilter = mainContract.Log({}, {fromBlock: $scope.boundary});
    $scope.logs = new filtered_list($scope.logFilter, function() { if (!$scope.$$phase) $scope.$apply(); });
    $scope.logString = "";
    $scope.accounts = eth.accounts;
    $scope.myAccount = "";
    window.mainScope = $scope;
    var onBlock = function(err, block) {
        eth.getBlockNumber(function(err, blockNumber) {
            mainContract.getLatestBreak.call({from: eth.accounts[0]}, function(err, res) {
                var res2 = web3.toDecimal(res);
                if (res2 != $scope.boundary) {
                    $scope.boundary = res2;
                    console.log('updating filter', $scope.boundary);
                    $scope.logs.shutdown();
                    $scope.logFilter = mainContract.Log({}, {fromBlock: $scope.boundary});
                    $scope.logs = new filtered_list($scope.logFilter);
                }
                if (!$scope.$$phase) $scope.$apply();
            });
        });
    }
    setInterval(function() { if (!$scope.$$phase) $scope.$apply(); }, 200);
    $scope.boundary = 419999;
    eth.filter('latest', onBlock);
    onBlock();
    $scope.addLog = function() {
        mainContract.addLog($scope.logString, {from: $scope.myAccount}, function(err, result) {
            if (err) { alert(err); return; }
            console.log('sending tx: ', result);
            $scope.logs.addLog({
                transactionHash: result,
                args: { value: $scope.logString }
            })
        });
    }
    $scope.addBreak = function() {
        var x = mainContract.addBreak({from: $scope.myAccount});
        console.log('sending tx: ', x);
    }
}
