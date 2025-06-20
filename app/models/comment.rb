class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :journal_submission

  validates :content, presence: true
  validates :user, presence: true

  scope :ordered, -> { order(:created_at) }

  def from_instructor?
    user.instructor? || user.administrator?
  end
end
