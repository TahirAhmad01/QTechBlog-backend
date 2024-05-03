class HomeController < ApplicationController
  def index
    render json:{
      data: current_user
    }
  end
end
