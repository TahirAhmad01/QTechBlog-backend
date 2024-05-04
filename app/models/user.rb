class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :first_name, :last_name, presence: true, length: {minimum: 2}
  validates :username, presence: true, uniqueness: true

  def self.jwt_revoked?(payload, user)
    token = user.jwt_allowlists.where(jti: payload['jti'], aud: payload['aud']).order(created_at: :desc).first
    return true if token.blank?

    token.update(exp: Time.current + 2.minutes.to_i)
    false
  end

end
