class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    if user
      user.generate_password_reset_token!
      UserMailer.password_reset(user).deliver_now
      redirect_to login_path, notice: "Se enviaron las instrucciones para restablecer tu contraseña"
    else
      flash.now[:alert] = "Email no encontrado"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find_by(reset_password_token: params[:id])
    if @user.nil? || !@user.password_reset_token_valid?
      redirect_to new_password_reset_path, alert: "Token inválido o expirado"
    end
  end

  def update
    @user = User.find_by(reset_password_token: params[:id])
    if @user.nil? || !@user.password_reset_token_valid?
      redirect_to new_password_reset_path, alert: "Token inválido o expirado"
      return
    end

    if @user.update(password_params)
      @user.clear_password_reset_token!
      redirect_to login_path, notice: "Contraseña actualizada correctamente. Por favor inicia sesión."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
