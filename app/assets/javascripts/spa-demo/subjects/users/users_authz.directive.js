(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .directive("sdUsersAuthz", UsersAuthzDirective);

  UsersAuthzDirective.$inject = [];

  function UsersAuthzDirective() {
    var directive = {
        bindToController: true,
        controller: UsersAuthzController,
        controllerAs: "vm",
        restrict: "A",
        link: link
    };
    return directive;

    function link(scope, element, attrs) {
      console.log("UsersAuthzDirective", scope);
    }
  }

  UsersAuthzController.$inject = ["$scope",
                                   "spa-demo.subjects.UsersAuthz"];
  function UsersAuthzController($scope, UsersAuthz) {
    var vm = this;
    vm.authz={};
    vm.authz.canUpdateItem = canUpdateItem;
    vm.newItem=newItem;

    activate();
    return;
    //////////
    function activate() {
      vm.newItem(null);
    }

    function newItem(item) {
      UsersAuthz.getAuthorizedUser().then(
        function(user){ authzUserItem(item, user); },
        function(user){ authzUserItem(item, user); });
    }

    function authzUserItem(item, user) {
      console.log("new Item/Authz", item, user);

      vm.authz.authenticated = UsersAuthz.isAuthenticated();
      vm.authz.canQuery      = UsersAuthz.canQuery();
      vm.authz.canCreate = UsersAuthz.canCreate();
      if (item && item.$promise) {
        vm.authz.canUpdate     = false;
        vm.authz.canDelete     = false;
        item.$promise.then(function(){ checkAccess(item); });
      } else {
        checkAccess(item)
      }
    }

    function checkAccess(item) {
      vm.authz.canUpdate     = UsersAuthz.canUpdate(item);
      vm.authz.canDelete     = UsersAuthz.canDelete(item);
      console.log("checkAccess", item, vm.authz);
    }

    function canUpdateItem(item) {
      return UsersAuthz.canUpdate(item);
    }
  }
})();
