class User < ApplicationRecord
  has_many :login_tokens, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(email) { email.strip.downcase }

  def generate_login_token
    login_tokens.create!(
      token_digest: SecureRandom.urlsafe_base64(32),
      expires_at: 1.hour.from_now
    )
  end
end
