(function() {
  "use strict";

  angular
    .module("spa-demo.layout")
    .component("sdNavbar", {
      templateUrl: templateUrl,
      controller: NavbarController
    });


  templateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function templateUrl(APP_CONFIG) {
    return APP_CONFIG.navbar_html;
  }

  NavbarController.$inject = ["$scope","spa-demo.authn.Authn", "spa-demo.authz.Authz"];
  function NavbarController($scope, Authn, Authz) {
    var vm=this;
    vm.getLoginLabel = getLoginLabel;
    vm.isAdmin = isAdmin;

    vm.$onInit = function() {
      console.log("NavbarController",$scope);
    }
    return;
    //////////////
    function getLoginLabel() {
      return Authn.isAuthenticated() ? Authn.getCurrentUserName() : "Login";
    }

    function isAdmin() {
      return Authz.isAdmin();
    }
  }
})();
