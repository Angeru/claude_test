module Admin
  class BaseController < ApplicationController
    before_action :require_login
    before_action :require_admin

    private

    def require_admin
      unless current_user&.admin?
        redirect_to dashboard_path, alert: "No tienes permisos para acceder a esta sección"
      end
    end
  end
end
