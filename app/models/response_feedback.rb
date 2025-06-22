class ResponseFeedback < ApplicationRecord
  belongs_to :response
  belongs_to :user
  
  # Self-referential association for threading
  belongs_to :parent, class_name: 'ResponseFeedback', optional: true
  has_many :replies, class_name: 'ResponseFeedback', foreign_key: 'parent_id', dependent: :destroy
  
  # Validations
  validates :content, presence: true, length: { minimum: 1, maximum: 10_000 }
  validate :feedback_limit_not_exceeded
  validate :journal_must_be_submitted
  validate :can_only_reply_to_same_response
  
  # Scopes
  scope :root_messages, -> { where(parent_id: nil) }
  scope :unread_by_student, -> { where(read_by_student: false) }
  scope :ordered, -> { order(position: :asc, created_at: :asc) }
  
  # Callbacks
  before_create :set_position
  after_create :update_response_counters
  after_create :send_notification
  after_update :update_read_counters, if: :saved_change_to_read_by_student?
  
  # Constants
  MAX_FEEDBACK_PER_RESPONSE = 150
  
  def student
    response.user
  end
  
  def instructor?
    user.instructor? || user.administrator?
  end
  
  def from_student?
    user == student
  end
  
  def mark_as_read!
    return if read_by_student
    update!(read_by_student: true)
  end
  
  def thread_count
    if parent_id.nil?
      replies.count + 1
    else
      parent.replies.count + 1
    end
  end
  
  private
  
  def feedback_limit_not_exceeded
    return unless response
    
    existing_count = response.response_feedbacks.count
    if existing_count >= MAX_FEEDBACK_PER_RESPONSE
      errors.add(:base, "Feedback limit of #{MAX_FEEDBACK_PER_RESPONSE} messages has been reached")
    end
  end
  
  def journal_must_be_submitted
    return unless response
    
    submission = response.user.journal_submissions.find_by(journal: response.journal)
    unless submission&.submitted?
      errors.add(:base, "Feedback can only be added to submitted journals")
    end
  end
  
  def can_only_reply_to_same_response
    return unless parent_id.present?
    
    if parent && parent.response_id != response_id
      errors.add(:base, "Replies must be to the same response")
    end
  end
  
  def set_position
    self.position = (response.response_feedbacks.maximum(:position) || 0) + 1
  end
  
  def update_response_counters
    # Manually update feedback count
    response.update_column(:feedback_count, response.response_feedbacks.count)
    
    # Update unread count if this is from instructor
    if instructor? && !read_by_student
      response.increment!(:unread_feedback_count)
    end
    
    response.update_column(:last_feedback_at, Time.current)
  end
  
  def update_read_counters
    if read_by_student && instructor?
      response.decrement!(:unread_feedback_count)
    end
  end
  
  def send_notification
    # Send notification to appropriate party
    if from_student?
      # Notify instructor of student reply
      FeedbackNotificationJob.perform_later(self, :student_replied)
    else
      # Notify student of instructor feedback
      FeedbackNotificationJob.perform_later(self, :instructor_feedback)
    end
  end
end
