class UsersController < ApplicationController
  def new
    redirect_to login_path
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Cuenta creada correctamente"
    else
      render "sessions/new", status: :unprocessable_entity, layout: "auth"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
