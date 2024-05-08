class Api::V1::CommentsController < ApiController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_blog
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :set_page, only: [:index]

  def index
    @parent_comments = @blog.comments.where(parent_id: nil)
                            .includes(replies: { replies: :replies })
                            .order(id: :asc).paginate(page: params[:page], per_page: params[:per_page].to_i.positive? ? params[:per_page].to_i : 10)

    sorted_comments = sort_comments(@parent_comments)
    pagination_info = {
      total_pages: @parent_comments.total_pages,
      current_page: @parent_comments.current_page,
      next_page: @parent_comments.next_page,
      prev_page: @parent_comments.previous_page
    }

    render json: { status: "success", data: sorted_comments.map { |comment| format_comment_with_replies(comment) }, pagination: pagination_info }
  end

  def show
    if @comment
      render json: { status: "success", data: format_comment_with_replies(@comment) }
    else
      render json: { error: 'Comment not found' }, status: :not_found
    end
  end

  def create
    @comment = @blog.comments.new(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
      render json: { status: "success", message: "Blog create successfully", data: @comment}, status: :created
    else
      render json: { status: "Failed", message: "Blog create Failed", error: @comment.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_update_params)
      render json: { status: "success", message: "Comment update successfully", data: @comment }, status: :ok
    else
      render json: { status: "error", message: "Comment update failed", error: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @comment.destroy
      render json: { message: 'Comment deleted successfully', data: @comment }, status: :ok
    else
      render json: { status: "error", message: "Comment delete failed", error: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_blog
    @blog = Blog.find(params[:blog_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Blog not found' }, status: :not_found
  end

  def set_comment
    @comment = @blog.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Comment not found' }, status: :not_found
  end

  def set_page
    @page = params[:page]&.to_i || 1
  end

  def comment_params
    params.require(:comment).permit(:comment, :parent_id)
  end

  def comment_update_params
    params.require(:comment).permit(:comment)
  end

  def sort_comments(comments)
    sorted_comments = comments.to_a.sort_by(&:id)
    sorted_comments.each do |comment|
      comment.replies = comment.replies.sort_by(&:id)
      comment.replies.each do |reply|
        reply.replies = reply.replies.sort_by(&:id)
      end
    end
    sorted_comments
  end

  def format_comment_with_replies(comment)
    {
      id: comment.id,
      comment: comment.comment,
      parent_comment_id: comment.parent_id,
      blog_id: comment.blog_id,
      user_id: comment.user_id,
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      replies: comment.replies.map { |reply| format_comment_with_replies(reply) }
    }
  end
end
