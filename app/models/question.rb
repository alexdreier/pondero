class Question < ApplicationRecord
  belongs_to :journal
  belongs_to :section, optional: true
  has_many :responses, dependent: :destroy
  
  # Enable rich text content
  has_rich_text :content
  has_rich_text :description
  
  # Enable drag-and-drop ordering
  acts_as_list scope: :journal

  # Remove direct content validation since it's now handled by rich_text
  validates :question_type, presence: true
  validates :position, presence: true, uniqueness: { scope: :journal_id }

  QUESTION_TYPES = %w[
    single_response
    multiple_response
    ranking
    choice
    free_text
    likert_scale
    instructional_text
    file_upload
  ].freeze

  validates :question_type, inclusion: { in: QUESTION_TYPES }

  scope :ordered, -> { order(:position) }

  def options_array
    return [] unless options.present?
    JSON.parse(options)
  rescue JSON::ParserError
    []
  end

  def options_array=(array)
    self.options = array.to_json
  end

  def requires_options?
    %w[choice ranking multiple_response likert_scale].include?(question_type)
  end

  def allows_multiple?
    %w[multiple_response ranking].include?(question_type)
  end
end
