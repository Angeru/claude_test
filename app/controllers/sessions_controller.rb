class SessionsController < ApplicationController
  layout "auth", only: [:new, :create]

  # Redirigir usuarios ya autenticados
  before_action :redirect_if_logged_in, only: [:new]

  def new
    @user = User.new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:last_activity_at] = Time.current.iso8601

      # Check for return_to path (after timeout redirect)
      return_to = session.delete(:return_to)

      if return_to.present?
        redirect_to return_to, notice: "Sesión iniciada correctamente"
      elsif user.campaigns.exists?
        redirect_to dashboard_path, notice: "Sesión iniciada correctamente"
      else
        redirect_to campaigns_path, notice: "Sesión iniciada correctamente. ¡Explora campañas disponibles!"
      end
    else
      flash.now[:alert] = "Email o contraseña inválidos"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Sesión cerrada correctamente"
  end

  private

  def redirect_if_logged_in
    return unless logged_in?

    if current_user.campaigns.exists?
      redirect_to dashboard_path
    else
      redirect_to campaigns_path
    end
  end
end
