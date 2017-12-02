class UserPolicy < ApplicationPolicy
  def index?
    @user.is_admin?
  end
  def show?
    @user.is_admin? || (@record.id == @user.id)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
