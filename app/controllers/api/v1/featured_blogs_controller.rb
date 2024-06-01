class Api::V1::FeaturedBlogsController < ApiController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    limit = params[:limit].to_i
    set_limit = limit.present? ? (limit + 50) : 20
    newest_blogs = Blog.order(created_at: :desc).limit(set_limit)
    most_viewed_blogs = Blog.order(views_count: :desc).limit(set_limit)
    combined_blogs = (newest_blogs + most_viewed_blogs).uniq { |blog| blog.id }

    sorted_featured_blogs = combined_blogs.sort_by { |blog| -blog.views_count }.take(limit.present? ? limit : 20)
    if sorted_featured_blogs.any?
      render json: { status: 'success', data: sorted_featured_blogs, total: sorted_featured_blogs.count }, status: :ok
    else
      render json: { status: 'success', message: 'No blogs found', data: sorted_featured_blogs }, status: :not_found
    end
  rescue StandardError => e
    render json: { status: 'error', message: e.message }, status: :internal_server_error
  end
end