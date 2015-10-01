// Directive for showing a dialog, eg. for errors. To open the dialog,
// simply set dialogMessage.body and dialogMessage.title to something
// nonnull. Note that dialogMessage.title is a string and
// dialogMessage.body is HTML.
app.directive('message', function() {

    var controller = function($scope, $rootScope) {
        window.messageSubScope = $scope;
        $rootScope.dialogMessage = null;
    }
    var template = '<div class="modal" ng-show="dialogMessage.body" style="width: 740px">' +
                        '<div class="modal-header">' +
                            '<span>{{ dialogMessage.title }}</span>' +
                            '<span style="float:right" ng-click="dialogMessage.body = null; dialogMessage.title = null;">x</span>' +
                        '</div>' +
                        '<div class="modal-body" style="text-align:justify" ng-bind-html-unsafe="dialogMessage.body">' +
                        '</div>' +
                        '<div class="modal-footer">' +
                            '<button class="btn" ng-click="dialogMessage.body = null; dialogMessage.title = null;"> Close</button>' +
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
