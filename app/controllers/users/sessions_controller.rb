class Users::SessionsController < Devise::SessionsController
  # include RackSessionsFix
  respond_to :json

  def create
    super do |user|
      if user.persisted?
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
        render json: { message: "User signed in successfully", user: user, access_token: token }, status: :ok
        return
      else
        render json: { message: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private
  def respond_to_on_destroy
    token = extract_token_from_headers(request.headers['Authorization'])

    if token.present?
      jwt_payload = decode_jwt_token(token)
      current_user = User.find_by(id: jwt_payload['sub'])

      if current_user
        if blacklisted_token?(token)
          render json: {
            status: 400,
            message: 'User is already logged out.'
          }, status: :bad_request
        else
          invalidate_jwt_token(token, current_user)
          render json: {
            status: 200,
            message: 'Logged out successfully.'
          }, status: :ok
        end
      else
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    else
      render json: {
        status: 400,
        message: 'Missing Authorization token.'
      }, status: :bad_request
    end
  end

  def extract_token_from_headers(authorization_header)
    authorization_header&.split(' ')&.last
  end

  def decode_jwt_token(token)
    JWT.decode(token, ENV['JWT_SECRET_KEY']).first
  end

  def invalidate_jwt_token(token, user)
    BlacklistedToken.create(token: token, user: user)
  end

  def blacklisted_token?(token)
    BlacklistedToken.exists?(token: token)
  end
end
