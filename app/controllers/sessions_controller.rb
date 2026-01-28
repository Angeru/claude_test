class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Sesión iniciada correctamente"
    else
      flash.now[:alert] = "Email o contraseña inválidos"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Sesión cerrada correctamente"
  end
end
