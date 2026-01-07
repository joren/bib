class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :verify, :sent]

  def new
    # Show email input form
  end

  def create
    user = User.find_by(email: params[:email])

    if user.present?
      token = user.generate_login_token
      LoginMailer.magic_link(user, token).deliver_later
    end

    redirect_to login_sent_path, notice: "Check your email for a login link!"
  end

  def verify
    token = LoginToken.valid.find_by(token_digest: params[:token])

    if token&.valid_for_authentication?
      token.mark_as_used!
      token.user.update(last_sign_in_at: Time.current)

      session[:user_id] = token.user.id
      redirect_to root_path, notice: "Successfully signed in!"
    else
      redirect_to new_session_path, alert: "Invalid or expired login link"
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to new_session_path, notice: "Signed out successfully"
  end

  def sent
    # Confirmation page after requesting login
  end
end
