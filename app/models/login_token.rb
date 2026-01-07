class LoginToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :valid, -> { where(used_at: nil).where("expires_at > ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def used?
    used_at.present?
  end

  def valid_for_authentication?
    !expired? && !used?
  end

  def mark_as_used!
    update!(used_at: Time.current)
  end
end
