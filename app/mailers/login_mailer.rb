class LoginMailer < ApplicationMailer
  default from: "noreply@bib.family"

  def magic_link(user, token)
    @user = user
    @login_url = verify_session_url(token: token)
    @expires_at = 1.hour.from_now

    mail(to: user.email, subject: "Sign in to Bib")
  end
end
