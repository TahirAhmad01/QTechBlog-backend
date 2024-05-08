class Blog < ApplicationRecord
  belongs_to :user
  has_many :comment, dependent: :destroy
  has_and_belongs_to_many :tag

  enum blog_status: {
    draft: 0,
    published: 1,
    archived: 2,
    active: 3
  }

  validates :title, presence: true, length: { minimum: 10 }
  validates :body, presence: true, length: { minimum: 10 }
  validates :description, :short_description, :slug, presence: true
  validate :tags_presence
  validates :blog_status, presence: true, inclusion: { in: blog_statuses.keys }

  after_initialize :set_default_status, if: :new_record?

  private

  def tags_presence
    errors.add(:tags, "can't be blank") unless tags.present?
    tags.each do |tag|
      errors.add(:tags, "tag '#{tag}' does not exist") unless Tag.exists?(name: tag)
    end if tags.present?
  end

  def set_default_status
    self.blog_status ||= :draft
  end
end
