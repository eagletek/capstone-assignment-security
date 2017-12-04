class RolePolicy < ApplicationPolicy
  def self_or_admin?
    (@user.id == @record.user_id) || @user.is_admin?
  end

  def index?
    @user
  end
  def create?
    @user
  end
  def update?
    false
  end
  def destroy?
    self_or_admin?
  end

  class Scope < Scope
    def by_model mname, mid

      return scope.none if !@user

      scope = scope.where(role_name:[Role::ORGANIZER, Role::MEMBER])
                   .where(mname:mname, mid:mid)

      # can see other members of same things
      if @user.is_admin? or scope.where(user_id:@user.id).exists?
        scope
      else
        scope.none
      end
    end
    def by_user
      return scope.none if !@user

      if @user.is_admin?
        scope.all
      else
        # can see own
        scope.where("user_id=#{@user.id}")
      end
    end

    def resolve
      by_user
    end
  end
end
