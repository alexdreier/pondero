class Section < ApplicationRecord
  belongs_to :journal
  has_many :questions, -> { order(:position) }, dependent: :destroy
  
  # Enable rich text description
  has_rich_text :description
  
  validates :title, presence: true
  validates :position, presence: true, uniqueness: { scope: :journal_id }
  
  scope :ordered, -> { order(:position) }
  
  # Use acts_as_list for drag-and-drop ordering
  acts_as_list scope: :journal
  
  def display_title
    title.present? ? title : "Section #{position}"
  end
  
  def questions_count
    questions.count
  end
end
