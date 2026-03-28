class MemberProfilesController < ApplicationController
  before_action :require_login
  before_action :block_user_access

  def index; end
  def show; end
  def new; end
  def create; end
  def edit; end
  def update; end
  def destroy; end

  private

  def block_user_access
    redirect_to dashboard_path, alert: "Los perfiles ahora son gestionados por el sistema según la clase de tu warband."
  end
end
