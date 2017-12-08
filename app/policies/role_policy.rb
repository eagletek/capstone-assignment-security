class RolePolicy < ApplicationPolicy
  def self_or_admin?
    admin? or (@user.id == @record.user_id)
  end
  def admin_count
    scope.where(role_name: Role::ADMIN).count
  end
  def organizer_of_same?
    scope.where(user_id: @user.id,
                role_name: Role::ORGANIZER,
                mname: @record.mname,
                mid: @record.mid).exists?
  end
  def organizer_count
    scope.where(role_name: Role::ORGANIZER,
                mname: @record.mname,
                mid: @record.mid).count
  end

  def index?
    @user
  end

  def show?
    self_or_admin? and scope.where(:id => record.id).exists?
  end

  def create?
    case record.role_name
    when Role::ADMIN
      admin?
    when Role::ORIGINATOR
      admin?
    when Role::ORGANIZER, Role::MEMBER
      organizer_of_same?
    else
      false
    end
  end

  def update?
    # Roles are immutable
    false
  end

  def destroy?
    case record.role_name
    when Role::ADMIN
      admin? and admin_count > 1
    when Role::ORIGINATOR
      self_or_admin?
    when Role::ORGANIZER
      organizer_of_same? and organizer_count > 1
    when Role::MEMBER
      organizer_of_same?
    else
      false
    end
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
