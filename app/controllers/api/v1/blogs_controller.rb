class Api::V1::BlogsController < ApiController

  before_action :set_blog, only: [:show, :update, :destroy]

  def index
    @blogs = Blog.all
    if @blogs.size > 0
      render json: { status: 'success', data: blog_json(@blog), total_blog: @blogs.size }, status: :ok
    else
      render json: { status: 'Success', message: "blogs not created yet", data: @blogs, total_blog: @blogs.size }, status: :ok
    end

  end

  def show
    render json: { status: 'Success', data: @blog }, status: :ok
  rescue Exception => e
    render json: { message: e.message, status: 404 }, status: :not_found
  end

  def create
    @blog = current_user.blogs.new(blog_params)
    if @blog.save
      render json: { message: "Blog created successfully", data: @blog, status: 200 }, status: :created
    else
      errors_array = @blog.errors.messages.map do |attribute, messages|
        { name: attribute, errors: messages }
      end
      render json: { message: "Blog create failed", errors: errors_array, status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      render json: { message: "Blog updated successfully", data: @blog, status: 200 }, status: :ok
    else
      errors_array = @blog.errors.messages.map do |attribute, messages|
        { name: attribute, errors: messages }
      end
      render json: { message: "Blog update failed", errors: errors_array, status: :unprocessable_entity }
    end
  end

  def destroy
    if @blog
      if @blog.destroy
        render json: { message: "Blog deleted successfully", status: 200, data: @blog }, status: :ok
      else
        render json: { message: "Blog delete failed", status: 404 }, status: :not_found
      end
    else
      render json: { message: "Blog not found", status: 404 }, status: :not_found
    end
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :description, :short_description, :body, :slug, :blog_status, :user_id, tags: [])
  end


  def blog_json(blog)
    puts "Blog Status in Serializer: #{blog&.blog_status}"
    blog.attributes.merge(blog_status: blog.blog_status.to_s)
  end
end