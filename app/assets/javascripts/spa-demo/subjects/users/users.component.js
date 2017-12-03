(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdUserSelector", {
      templateUrl: userSelectorTemplateUrl,
      controller: UserSelectorController,
      bindings: {
        authz: "<"
      },
    })
    .component("sdUserEditor", {
      templateUrl: userEditorTemplateUrl,
      controller: UserEditorController,
      bindings: {
        authz: "<"
      },
      require: {
        usersAuthz: "^sdUsersAuthz"
      }
    });


  userSelectorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function userSelectorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.user_selector_html;
  }
  userEditorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function userEditorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.user_editor_html;
  }

  UserSelectorController.$inject = ["$scope",
                                     "$stateParams",
                                     "spa-demo.authz.Authz",
                                     "spa-demo.subjects.User"];
  function UserSelectorController($scope, $stateParams, Authz, User) {
    var vm=this;

    vm.$onInit = function() {
      console.log("UserSelectorController",$scope);
      $scope.$watch(function(){ return Authz.getAuthorizedUserId(); },
                    function(){
                      if (!$stateParams.id) {
                        vm.items = User.query();
                      }
                    });
    }
    return;
    //////////////
  }


  UserEditorController.$inject = ["$scope","$q",
                                   "$state", "$stateParams",
                                   "spa-demo.authz.Authz",
                                   "spa-demo.subjects.User",
                                   ];
  function UserEditorController($scope, $q, $state, $stateParams,
                                 Authz, User) {
    var vm=this;
    vm.clear = clear;
    vm.create = create;
    vm.remove  = remove;
    vm.isAdmin = Authz.isAdmin;
    vm.haveDirtyRoles = haveDirtyRoles;

    vm.$onInit = function() {
      console.log("UserEditorController",$scope);
      $scope.$watch(function(){ return Authz.getAuthorizedUserId(); },
                    function(){
                      if ($stateParams.id) {
                        reload($stateParams.id);
                      } else {
                        newResource();
                      }
                    });
    }
    return;
    //////////////
    function newResource() {
      console.log("newResource()");
      vm.item = new User();
      vm.usersAuthz.newItem(vm.item);
      return vm.item;
    }

    function reload(userId) {
      var itemId = userId ? userId : vm.item.id;
      console.log("re/loading user", itemId);
      vm.item = User.get({id:itemId});
      vm.usersAuthz.newItem(vm.item);
      $q.all([vm.item.$promise]).catch(handleError);
    }

    function clear() {
      newResource();
      $state.go(".", {id:null});
    }

    function haveDirtyRoles() {
      for (var i=0; vm.item.roles && i<vm.item.roles.length; i++) {
        var role=vm.item.roles[i];
        if (role.toRemove) {
          return true;
        }
      }
      return false;
    }

    function create() {
      vm.item.$save().then(
        function(){
           $state.go(".", {id: vm.item.id});
        },
        handleError);
    }

    function remove() {
      vm.item.errors = null;
      vm.item.$delete().then(
        function(){
          console.log("remove complete", vm.item);
          clear();
        },
        handleError);
    }


    function handleError(response) {
      console.log("error", response);
      if (response.data) {
        vm.item["errors"]=response.data.errors;
      }
      if (!vm.item.errors) {
        vm.item["errors"]={}
        vm.item["errors"]["full_messages"]=[response];
      }
      $scope.userform.$setPristine();
    }
  }

})();
