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
  
  include CompletionCalculable

  private

  def completion_responses
    responses.joins(:question).where(questions: { required: true })
  end

  def completion_all_responses
    responses.joins(:question)
  end
  
  def display_title
    title.present? ? title : "Entry for #{entry_date&.strftime('%B %d, %Y') || 'Unknown Date'}"
  end
end
