class Response < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :journal_entry, optional: true
  has_one :journal, through: :question
  
  # Enable rich text content for free text responses
  has_rich_text :content

  validates :user_id, uniqueness: { scope: [:question_id, :journal_entry_id] }

  enum :status, {
    draft: 'draft',
    submitted: 'submitted'
  }

  scope :submitted, -> { where(status: 'submitted') }
  scope :for_journal, ->(journal) { joins(:question).where(questions: { journal: journal }) }

  def submitted?
    status == 'submitted' && submitted_at.present?
  end

  def submit!
    update!(status: 'submitted', submitted_at: Time.current)
  end
end
