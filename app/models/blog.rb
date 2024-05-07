class Blog < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

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
  end

  def set_default_status
    self.blog_status ||= :draft
  end
end
