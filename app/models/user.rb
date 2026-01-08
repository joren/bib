class User < ApplicationRecord
  include PasswordlessAuthentication

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
