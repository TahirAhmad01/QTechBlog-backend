class Api::V1::BlogsController < ApiController
  skip_before_action :authenticate_user!, only: [:index, :show, :search]
  before_action :set_blog, only: [:show, :update, :destroy]
  before_action :set_page, only: [:index, :search]

  def index
    @blogs = Blog.paginate(page: @page, per_page: params[:per_page].to_i.positive? ? params[:per_page].to_i : 10)
    @total_blogs = Blog.count

    pagination_info = {
      total_pages: @blogs.total_pages,
      current_page: @blogs.current_page,
      next_page: @blogs.next_page,
      prev_page: @blogs.previous_page
    }

    response.headers.merge!(
      'X-Total-Count' => @total_blogs.to_s,
      'X-Per-Page' => @blogs.per_page.to_s,
      'Link' => pagination_links(@blogs)
    )

    if @blogs.any?
      render json: { status: 'success', data: @blogs, total_blog: @total_blogs, pagination: pagination_info }, status: :ok
    else
      render json: { status: 'success', message: "No blogs found", data: [], total_blog: @total_blogs, pagination: pagination_info }, status: :ok
    end
  rescue WillPaginate::InvalidPage => exception
    render json: { status: 'error', message: exception.message }, status: :bad_request
  rescue StandardError => e
    render json: { status: 'error', message: e.message }, status: :internal_server_error
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
      render json: { message: "Blog create failed", errors: @blog.errors, status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def update
    @blog.slug = generate_slug(blog_params[:title])
    if @blog.update(blog_params)
      render json: { message: "Blog updated successfully", data: blog_json(@blog) }, status: :ok
    else
      render json: { message: "Blog update failed", errors: @blog.errors, status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def destroy
    if @blog.destroy
      render json: { message: "Blog deleted successfully", data: blog_json(@blog) }, status: :ok
    else
      render json: { message: "Blog delete failed", status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def search
    query = params[:q].downcase

    if query.present?
      @blogs = Blog.where('LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(body) LIKE ? OR LOWER(tags::text) LIKE ?', "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
                   .paginate(page: @page, per_page: params[:per_page].to_i.positive? ? params[:per_page].to_i : 30)

      pagination_info = {
        total_pages: @blogs.total_pages,
        current_page: @blogs.current_page,
        next_page: @blogs.next_page,
        prev_page: @blogs.previous_page
      }

      render json: { status: 'success', data: @blogs, total: @blogs.count, pagination: pagination_info }, status: :ok
    else
      render json: { status: 'error', message: 'Query parameter "q" is missing' }, status: :bad_request
    end
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { status: "error", message: e.message }, status: :not_found
  end

  def blog_params
    params.require(:blog).permit(:title, :description, :short_description, :body, :blog_status, :user_id, :category_id, tags: [])
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

  def pagination_links(collection)
    links = []
    links << "<#{request.base_url}#{request.path}?page=#{collection.next_page}>; rel=\"next\"" if collection.next_page
    links << "<#{request.base_url}#{request.path}?page=#{collection.previous_page}>; rel=\"prev\"" if collection.previous_page
    links << "<#{request.base_url}#{request.path}?page=#{collection.total_pages}>; rel=\"last\""
    links.join(', ').presence
  end
end
