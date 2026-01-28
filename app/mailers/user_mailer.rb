class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @reset_url = edit_password_reset_url(user.reset_password_token)
    mail(to: user.email, subject: "Instrucciones para restablecer tu contraseña")
  end
end
