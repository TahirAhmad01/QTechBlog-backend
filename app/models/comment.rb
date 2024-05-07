class Comment < ApplicationRecord
  belongs_to :blog, optional: true
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy

  validate :validate_parent_comment_level, on: :create
  validates :comment, presence: true
  validate :validate_parent_comment_exists, on: :create

  private

  def validate_parent_comment_level
    return if parent_id.blank?

    parent = Comment.find_by(id: parent_id)
    parent_level = 1

    while parent && parent.parent_id.present?
      parent_level += 1
      break if parent_level >= 3

      parent = Comment.find_by(id: parent.parent_id)
    end

    if parent_level >= 3
      errors.add(:parent_id, "can't be nested more than three levels deep")
    end
  end

  def validate_parent_comment_exists
    return if parent_id.blank?

    parent_comment = Comment.find_by(id: parent_id)

    if parent_comment.blank? || parent_comment.blog_id != blog_id
      errors.add(:parent_id, "must exist and belong to the same blog")
    end
  end
end
