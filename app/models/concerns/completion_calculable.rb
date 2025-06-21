module CompletionCalculable
  extend ActiveSupport::Concern

  def completion_percentage
    return 0 if journal.questions.empty?
    
    required_questions = journal.questions.where(required: true).count
    return 100 if required_questions == 0
    
    # Count responses for required questions that have non-empty content
    answered_questions = completion_responses
                           .select { |response| response.content.present? && response.content.to_plain_text.strip.present? }
                           .count
    
    (answered_questions.to_f / required_questions * 100).round
  end

  def all_required_answered?
    completion_percentage == 100
  end

  private

  # This method should be implemented by the including class
  # to return the appropriate responses collection
  def completion_responses
    raise NotImplementedError, "#{self.class} must implement #completion_responses"
  end
end