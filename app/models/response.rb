class Response < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :journal_entry, optional: true
  has_one :journal, through: :question
  
  # Enable rich text content for free text responses
  has_rich_text :content
  
  # Feedback system
  has_many :response_feedbacks, dependent: :destroy
  has_many :feedback_authors, through: :response_feedbacks, source: :user

  validates :user_id, uniqueness: { scope: [:question_id, :journal_entry_id] }

  enum :status, {
    draft: 'draft',
    submitted: 'submitted'
  }

  scope :submitted, -> { where(status: 'submitted') }
  scope :for_journal, ->(journal) { joins(:question).where(questions: { journal: journal }) }
  scope :with_feedback, -> { where('feedback_count > 0') }
  scope :with_unread_feedback, -> { where('unread_feedback_count > 0') }

  def submitted?
    status == 'submitted' && submitted_at.present?
  end

  def submit!
    update!(status: 'submitted', submitted_at: Time.current)
  end
  
  # Feedback methods
  def supports_feedback?
    question.question_type == 'free_text' && 
    content.present? && 
    content.to_s.strip.length > 50  # Only substantial responses get feedback
  end
  
  def has_feedback?
    feedback_count > 0
  end
  
  def has_unread_feedback?
    unread_feedback_count > 0
  end
  
  def feedback_conversation
    response_feedbacks.ordered
  end
  
  def mark_all_feedback_as_read!(user)
    return unless user == self.user # Only student can mark as read
    
    unread_feedback = response_feedbacks.unread_by_student
    unread_feedback.update_all(read_by_student: true)
    
    update_column(:unread_feedback_count, 0)
  end
  
  def latest_feedback
    response_feedbacks.order(created_at: :desc).first
  end
  
  def feedback_participants
    feedback_authors.distinct
  end
  
  def can_receive_feedback?(user)
    return false unless supports_feedback?
    return false unless submitted?
    return false if response_feedbacks.count >= ResponseFeedback::MAX_FEEDBACK_PER_RESPONSE
    
    # Instructors and admins can always give feedback
    return true if user.instructor? || user.administrator?
    
    # Students can only reply if there's existing feedback
    return false unless user == self.user
    has_feedback?
  end
end
