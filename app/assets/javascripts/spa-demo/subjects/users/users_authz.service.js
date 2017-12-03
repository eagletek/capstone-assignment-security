(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.UsersAuthz", UsersAuthzFactory);

  UsersAuthzFactory.$inject = ["spa-demo.authz.Authz",
                               "spa-demo.authz.BasePolicy"];
  function UsersAuthzFactory(Authz, BasePolicy) {
    function UsersAuthz() {
      BasePolicy.call(this, "User");
    }

      //start with base class prototype definitions
    UsersAuthz.prototype = Object.create(BasePolicy.prototype);
    UsersAuthz.constructor = UsersAuthz;

      //override and add additional methods
    UsersAuthz.prototype.canCreate=function() {
      return false;
    };

    UsersAuthz.prototype.canQuery=function(item) {
      if (!item) {
        return Authz.isAdmin();
      } else {
        return !item.id ? false : item.id == Authz.getAuthorizedUserId();
      }
    };

    UsersAuthz.prototype.canUpdate=function() {
      return false;
    };

    UsersAuthz.prototype.canDelete=function() {
      return false;
    };

    return new UsersAuthz();
  }
})();
