class Api::V1::HomeController < ApiController
  def index
    render json:{
      data: current_user
    }
  end
end
