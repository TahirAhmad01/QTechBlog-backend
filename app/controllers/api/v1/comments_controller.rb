class Api::V1::CommentsController < ApiController
  before_action :set_blog
  before_action :set_comment, only: [:show, :update, :destroy]

  def index
    @comments = @blog.comments.includes(:replies)
    render json: @comments.map { |comment| format_comment(comment, 3) }
  end

  def show
    if @comment
      render json: format_comment(@comment, 3)
    else
      render json: { error: 'Comment not found' }, status: :not_found
    end
  end


  def create
    @comment = @blog.comments.new(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    head :no_content
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

  def comment_params
    params.require(:comment).permit(:comment, :parent_id)
  end

  def format_comment(comment, level)
    return nil if level.zero?

    parent_comment_id = comment.parent_id
    parent_comment_id = nil if parent_comment_id.blank?
    {
      id: comment.id,
      comment: comment.comment,
      parent_comment_id: parent_comment_id,
      blog_id: comment.blog_id,
      user_id: comment.user_id,
      created_at: comment.created_at,
      updated_at: comment.updated_at,
      replies: comment.replies.map { |reply| format_comment(reply, level - 1) }
    }
  end
end
