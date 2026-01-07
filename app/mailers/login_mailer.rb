class LoginMailer < ApplicationMailer
  default from: "noreply@bib.family"

  def magic_link(user, login_token)
    @user = user
    @login_url = verify_session_url(token: login_token.token_digest)
    @expires_at = login_token.expires_at

    mail(to: user.email, subject: "Sign in to Bib")
  end
end
