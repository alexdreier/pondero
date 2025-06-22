module CompletionCalculable
  extend ActiveSupport::Concern

  def completion_percentage
    return 0 if journal.questions.empty?
    
    total_questions = journal.questions.count
    required_questions = journal.questions.where(required: true).count
    
    # If there are no required questions, calculate based on all questions
    if required_questions == 0
      all_responses = completion_all_responses
      answered_questions = all_responses
                             .select { |response| response.content.present? && response.content.to_s.strip.present? }
                             .count
      return (answered_questions.to_f / total_questions * 100).round
    end
    
    # Count responses for required questions that have non-empty content
    answered_questions = completion_responses
                           .select { |response| response.content.present? && response.content.to_s.strip.present? }
                           .count
    
    (answered_questions.to_f / required_questions * 100).round
  end

  def all_required_answered?
    completion_percentage == 100
  end

  private

  # This method should be implemented by the including class
  # to return the appropriate responses collection for required questions
  def completion_responses
    raise NotImplementedError, "#{self.class} must implement #completion_responses"
  end

  # This method should be implemented by the including class
  # to return all responses for the journal
  def completion_all_responses
    raise NotImplementedError, "#{self.class} must implement #completion_all_responses"
  end
end