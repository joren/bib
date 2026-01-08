module PasswordlessAuthentication
  extend ActiveSupport::Concern

  included do
    generates_token_for :login, expires_in: 1.hour
  end

  def generate_login_token
    generate_token_for(:login)
  end
end
