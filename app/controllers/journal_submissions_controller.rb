class JournalSubmissionsController < ApplicationController
  before_action :set_submission, only: [:show, :update]

  def show
    # Show submission details (for instructors) or journal view (for learners)
    @journal = @submission.journal
    
    if current_user.learner? && @submission.user != current_user
      redirect_to root_path, alert: 'Access denied.'
      return
    end
    
    if current_user.learner?
      # Redirect learners to the journal view instead
      redirect_to @journal
    else
      # Show instructor view of the submission
      @responses = @submission.user.responses.joins(:question)
                                .where(questions: { journal: @journal })
                                .includes(:question)
      @comments = @submission.comments.includes(:user).ordered
    end
  end

  def create
    # This would be used for creating a submission (auto-created in journal show)
    redirect_to root_path
  end

  def update
    # Handle submission completion and response updates
    if params[:responses].present?
      save_responses
    end

    if params[:submit_journal].present?
      if @submission.all_required_answered?
        @submission.complete!
        redirect_to @submission.journal, notice: 'Journal submitted successfully!'
      else
        redirect_to @submission.journal, alert: 'Please answer all required questions before submitting.'
      end
    else
      redirect_to @submission.journal, notice: 'Progress saved.'
    end
  end

  private

  def set_submission
    @submission = JournalSubmission.find(params[:id])
  end

  def save_responses
    params[:responses].each do |question_id, response_data|
      question = Question.find(question_id)
      response = current_user.responses.find_or_initialize_by(question: question)
      
      # Handle different response formats
      content = if response_data.is_a?(Hash) && response_data[:content].present?
                  response_data[:content]
                elsif response_data.is_a?(Array)
                  response_data.join(',') # For multiple choice
                else
                  response_data
                end
      
      if content.present?
        response.content = content
        response.save!
      end
    end
  end
end
