class JournalEntry < ApplicationRecord
  belongs_to :user
  belongs_to :journal
  has_many :responses, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  # Enable rich text description
  has_rich_text :description
  
  validates :title, presence: true
  validates :entry_date, presence: true
  validates :status, presence: true
  
  enum :status, {
    draft: 'draft',
    submitted: 'submitted',
    reviewed: 'reviewed'
  }
  
  scope :by_date, -> { order(:entry_date) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_journal, ->(journal) { where(journal: journal) }
  scope :for_user, ->(user) { where(user: user) }
  
  def submit!
    update!(status: 'submitted', submitted_at: Time.current)
  end
  
  def completion_percentage
    return 0 if journal.questions.where(required: true).empty?
    
    required_questions = journal.questions.where(required: true).count
    return 100 if required_questions == 0
    
    # Count responses for required questions that have non-empty content
    answered_questions = responses.joins(:question)
                                 .where(questions: { required: true })
                                 .select { |response| response.content.present? && response.content.to_plain_text.strip.present? }
                                 .count
    
    (answered_questions.to_f / required_questions * 100).round
  end
  
  def all_required_answered?
    completion_percentage == 100
  end
  
  def display_title
    title.present? ? title : "Entry for #{entry_date&.strftime('%B %d, %Y') || 'Unknown Date'}"
  end
end
