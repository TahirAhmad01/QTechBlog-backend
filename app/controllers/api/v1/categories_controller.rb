class Api::V1::CategoriesController < ApiController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_category, only: [:show, :update, :destroy]

  def index
    @categories = Category.all
    render json: @categories, status: 200
  end

  def show
    render json: @category, status: 200
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render json: @category, status: 201
    else
      render json: { errors: @category.errors.full_messages }, status: 422
    end
  end

  def update
    if @category.update(category_params)
      render json: @category, status: 200
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      render json: @category, status: 200
    else
      render json: { errors: @category.errors.full_messages }, status: 422
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Category not found" }, status: 404
  end

  def category_params
    params.require(:category).permit(:name)
  end
end