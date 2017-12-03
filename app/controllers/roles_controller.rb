class RolesController < ApplicationController
  before_action :set_role, only: [:show, :destroy]

  def index
    @users = User.with_roles
  end

  def show
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      render json: @role, status: :created, location: @role
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @role.destroy

    head :no_content
  end

  private

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:role_name, :mname, :mid)
    end
end
