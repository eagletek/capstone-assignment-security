class RolesController < ApplicationController
  before_action :set_role, only: [:show, :destroy]
  before_action :authenticate_user!, only: [:index, :create, :destroy]
  wrap_parameters :role, include: ["user_id", "role_name", "mname", "mid"]
  after_action :verify_authorized

  def index
    authorize Role
    roles = params.key?(:user_id) ? User.find(params[:user_id]).roles : Role.all

    policy = RolePolicy::Scope.new(current_user, roles)
    if params.key? :user_id
      @roles = policy.by_user
    elsif params[:thing_id]
      @roles = policy.by_model Thing.name, params[:thing_id]
    elsif params[:image_id]
      @roles = policy.by_model Image.name, params[:image_id]
    end
  end

  def show
    authorize @role
  end

  def create
    p = { "user_id"=> params[:user_id],
          "mname"=> nil,
          "mid"=> nil }
    if (params[:image_id])
      p["mname"] = Image.name
      p["mid"] = params[:image_id]
    elsif (params[:thing_id])
      p["mname"] = Thing.name
      p["mid"] = params[:thing_id]
    end

    p = p.merge(role_params)
    if p["role_name"] == Role::ADMIN
      p["mname"] = nil
      p["mid"] = nil
    elsif p["role_name"] == Role::ORIGINATOR
      p["mid"] = nil
    end
    @role = Role.new(p)
    authorize @role

    if @role.save
      render :show, status: :created, location: user_role_path(User.find(@role.user_id), @role)
    else
      render json: {errors:@role.errors.messages}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @role
    @role.destroy

    head :no_content
  end

  private

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:user_id, :role_name, :mname, :mid)
      params.require(:role).tap {|p|
          #_ids only required in payload when not part of URI
          p.require(:user_id)   if !params[:user_id]
          p.permit(:mid)        if !(params[:thing_id] || params[:image_id])
          p.permit(:mname)      if !(params[:thing_id] || params[:image_id])
          p.require(:role_name)
        }
    end
end
