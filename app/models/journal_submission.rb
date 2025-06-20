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

  def completion_percentage
    return 0 if journal.questions.empty?
    
    required_questions = journal.questions.where(required: true).count
    return 100 if required_questions == 0
    
    # Count responses for required questions that have non-empty content
    answered_questions = user.responses.joins(:question)
                                      .where(questions: { journal: journal, required: true })
                                      .select { |response| response.content.present? && response.content.to_plain_text.strip.present? }
                                      .count
    
    (answered_questions.to_f / required_questions * 100).round
  end

  def all_required_answered?
    completion_percentage == 100
  end
end
