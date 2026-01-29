class HomeController < ApplicationController
  def index
    # Usuarios anónimos ven el formulario de login
    unless logged_in?
      render 'sessions/new' and return
    end

    # Usuarios autenticados CON suscripciones → dashboard
    # Nota: Incluye tanto campañas suscritas como creadas
    if current_user.campaigns.exists?
      redirect_to dashboard_path
    else
      # Usuarios autenticados SIN suscripciones → índice de campañas
      redirect_to campaigns_path
    end
  end
end
