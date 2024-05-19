class User < ApplicationRecord
  has_many :blogs
  before_validation :set_user_role, on: :create

  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable,
         :jwt_authenticatable, jwt_revocation_strategy: self, omniauth_providers: [:facebook, :google_oauth2]

  ROLES = %w{super_admin admin author user}

  validates :first_name, :last_name, presence: true, length: { minimum: 2 }
  validates :username, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES }

  ROLES.each do |role_name|
    define_method "#{role_name}?" do
      role == role_name
    end
  end

  def jwt_payload
    super
  end

  def self.jwt_revoked?(payload, user)
    token = user.jwt_allowlists.where(jti: payload['jti'], aud: payload['aud']).order(created_at: :desc).first
    return true if token.blank?

    token.update(exp: Time.current + 2.minutes.to_i)
    false
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.first_name   # Assuming the provider returns a first_name field
      user.last_name = auth.info.last_name     # Assuming the provider returns a last_name field
      user.username = auth.info.name           # Assuming the provider returns a name field
    end
  end

  def generate_jwt
    JWT.encode({ id: id, exp: 365.days.from_now.to_i }, ENV['JWT_SECRET_KEY'])
  end


  private

  def set_user_role
    self.role ||= 'user'
  end
end
