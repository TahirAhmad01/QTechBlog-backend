class Api::V1::TagsController < ApiController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_tag, only: %i[show update destroy]

  def index
    @tags = Tag.all
    render json: { status: "success", data: @tags }, status: :ok
  end

  def show
    render json: { status: "success", data: @tag }, status: :ok
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render json: { status: "success", message: "Tag created successfully", data: @tag }, status: :created
    else
      render json: { status: "error", message: "Failed to create tag", errors: @tag.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      render json: { status: "success", message: "Tag updated successfully", data: @tag }, status: :ok
    else
      render json: { status: "error", message: "Failed to update tag", errors: @tag.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @tag.destroy
      render json: { status: "success", message: "Tag deleted successfully" }, status: :ok
    else
      render json: { status: "error", message: "Failed to delete tag", errors: @tag.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { status: "error", message: "Tag not found", error: e }, status: :not_found
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
