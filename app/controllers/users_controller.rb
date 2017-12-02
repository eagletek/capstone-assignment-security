class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize User
    @users = User.with_roles
  end

  def show
    authorize @user
  end

  private
    def set_user
      @user = User.find(params[:id])
    end
end
