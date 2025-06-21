class JournalSubmission < ApplicationRecord
  belongs_to :user
  belongs_to :journal
  has_many :comments, dependent: :destroy
  has_many :responses, -> { joins(:question).where(questions: { journal_id: journal.id }) }, 
           through: :user, source: :responses

  validates :user_id, uniqueness: { scope: :journal_id }

  enum :status, {
    in_progress: 'in_progress',
    submitted: 'submitted',
    reviewed: 'reviewed'
  }

  scope :completed, -> { where.not(completed_at: nil) }
  
  def complete!
    update!(status: 'submitted', completed_at: Time.current)
  end

  def submitted?
    status == 'submitted'
  end

  include CompletionCalculable

  private

  def completion_responses
    user.responses.joins(:question).where(questions: { journal: journal, required: true })
  end
end
