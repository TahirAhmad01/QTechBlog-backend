# app/controllers/omniauth_callbacks_controller.rb
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      token = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil).first
      render json: { user: @user, token: token }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def failure
    render json: { errors: "Authentication failed. ::" }, status: :unprocessable_entity
  end
end
