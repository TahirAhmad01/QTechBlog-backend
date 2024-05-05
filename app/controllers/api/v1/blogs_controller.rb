class Api::V1::BlogsController < ApiController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_blog, only: [:show, :update, :destroy]
  before_action :set_page, only: [:index]

  def index
    @blogs = Blog.paginate(page: @page, per_page: params[:per_page].present? ? params[:per_page].to_i : 10)
    @total_blogs = Blog.count

    response.headers['Pagination'] = {
      total_pages: @blogs.total_pages,
      current_page: @blogs.current_page,
      next_page: @blogs.next_page,
      prev_page: @blogs.previous_page,
      total_entries: @blogs.total_entries
    }.to_json

    pageInfo = {
      total_pages: @blogs.total_pages,
      current_page: @blogs.current_page,
      next_page: @blogs.next_page,
      prev_page: @blogs.previous_page,
    }

    if @blogs.any?
      render json: { status: 'success', data: @blogs, total_blog: @total_blogs, pagination: pageInfo }, status: :ok
    else
      render json: { status: 'success', message: "No blogs found", data: [], total_blog: 0, pagination: pageInfo }, status: :ok
    end
  rescue WillPaginate::InvalidPage => exception
    render json: { status: 'error', message: exception.message }, status: :bad_request
  end

  def show
    render json: { status: 'Success', data: @blog }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { message: e.message, status: :not_found }, status: :not_found
  end

  def create
    @blog = current_user.blogs.new(blog_params)
    @blog.slug = generate_slug(blog_params[:title])
    if @blog.save
      render json: { message: "Blog created successfully", data: blog_json(@blog) }, status: :created
    else
      render json: { message: "Blog create failed", errors: @blog.errors.full_messages, status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def update
    @blog.slug = generate_slug(blog_params[:title])
    if @blog.update(blog_params)
      render json: { message: "Blog updated successfully", data: blog_json(@blog) }, status: :ok
    else
      render json: { message: "Blog update failed", errors: @blog.errors.full_messages, status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def destroy
    if @blog.destroy
      render json: { message: "Blog deleted successfully", data: blog_json(@blog) }, status: :ok
    else
      render json: { message: "Blog delete failed", status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :description, :short_description, :body, :blog_status, :user_id, tags: [])
  end

  def blog_json(blog)
    blog.attributes.merge(blog_status: blog.blog_status.to_s)
  end

  def set_page
    @page = params[:page]&.to_i || 1
  end

  def generate_slug(title)
    title.parameterize
  end
end
