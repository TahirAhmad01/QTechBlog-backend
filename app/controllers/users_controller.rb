class UsersController < ApiController
  skip_before_action :authenticate_user!

  def show
    user = User.find(params[:id])
    render json: { message: "Success", data: user}
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end
end