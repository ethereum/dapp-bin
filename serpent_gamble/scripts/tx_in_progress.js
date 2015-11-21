// Directive for creating a transaction in progress dialog. To open
// the dialog, call $rootScope.addTransaction(h, description) where
// h is the transaction hash and description is a description of
// what the transaction is for (eg. "Updating contract seed")
app.directive('txInProgress', function() {

    var controller = function($scope, $rootScope) {
        window.txInProgressSubScope = $scope;

        $scope.txInProgress = {
            txhash: null,
            description: null,
            status: null,
            confirmations: null,
            timeSubmitted: null,
            showing: false
        }
        var obj = $scope.txInProgress;
        var eth = web3.eth;

        $rootScope.addTransaction = function(h, description, longDescription) {
            obj.txhash = h;
            obj.description = description;
            obj.longDescription = longDescription;
            obj.status = "Pending";
            obj.confirmations = 0;
            obj.timeSubmitted = new Date().getTime() / 1000;
            obj.showing = true;
        }

        // This function checks whether or not a function failed based on
        // its log output; if you want to change this function, feel free
        // to, returning 0 logs is a reasonable default way of checking
        // although it does require your transaction to create a log upon
        // success
        $scope.logFilter = function(logs) {
            return logs.length > 0;
        }

        // Update the status of the transaction that is currently being shown
        $scope.updateTransaction = function() {
            console.log('watching', obj);
            if (obj.txhash) {
                var r = eth.getTransactionReceipt(obj.txhash);
                console.log(r);
                if (r) {
                    obj.confirmations = eth.blockNumber - r.blockNumber + 1;
                    if (!$scope.logFilter(r.logs))
                        obj.status = 'Operation failed';
                    else
                        obj.status = (obj.confirmations >= 12) ? 'Confirmed' : 'Confirming';
                }
                else {
                    obj.confirmations = 0;
                    obj.status = 'Pending';
                }
                if ((new Date().getTime() / 1000) - obj.timeSubmitted > 300 && obj.status == 'Pending')
                    obj.status = 'Transaction sending failed';
            }
            $scope.$apply();
        }
        eth.filter('latest').watch($scope.updateTransaction);

    }
    // HTML template
    var template = '<div class="modal" ng-show="txInProgress.showing" style="width: 740px">' +
                        '<div class="modal-header">' +
                            '<span>{{ txInProgress.description }}</span>' +
                            '<span style="float:right" ng-click="txInProgress.showing = false">x</span>' +
                        '</div>' +
                        '<div class="modal-body" style="text-align:justify">' +
                            '<span ng-show="txInProgress.longDescription">{{ txInProgress.longDescription }}</span>' + 
                            '<table cellpadding="10px">' +
                                '<tr>' +
                                    '<td>Transaction hash:</td>' +
                                    '<td><a href="http://etherscan.io/tx/{{ txInProgress.txhash }}"> {{ txInProgress.txhash }}</a></td>' +
                                '</tr>' +
                                '<tr><td>Status:</td><td>{{ txInProgress.status }}</td></tr>' +
                                '<tr><td>Confirmations:</td><td>{{ txInProgress.confirmations }}</td></tr>' +
                            '</table>' + 
                            '<img style="float:right" src="images/inprogress.gif"></img>' +
                        '</div>' +
                        '<div class="modal-footer">' +
                            '<button class="btn" ng-click="txInProgress.showing = false"> Close</button>' +
                        '</div>' +
                    '</div>';

      return {
          restrict: 'EA', //Default for 1.3+
          scope: true,
          controller: controller,
          // controllerAs: 'vm',
          // bindToController: true, //required in 1.3+ with controllerAs
          template: template
      };
});
