class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    if current_user
      render json: {
        error: "You are already logged in",
        data: current_user,
        status: 401
      }
    else
      super do |user|
        if user.persisted?
          token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
          render json: { message: "User registration was successfully registered", user: user, access_token: token }, status: :ok
          return
        else
          errors_array = resource.errors.messages.map do |attribute, messages|
            { name: attribute, errors: messages }
          end
          render json: {
            error: "User registration failed", error_messages: errors_array
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
