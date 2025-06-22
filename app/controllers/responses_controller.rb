class ResponsesController < ApplicationController
  before_action :set_question, only: [:create, :update]
  
  def create
    journal_entry = JournalEntry.find(params[:journal_entry_id]) if params[:journal_entry_id]
    @response = current_user.responses.build(response_params)
    @response.question = @question
    @response.journal_entry = journal_entry if journal_entry
    
    if @response.save
      # Get or create journal submission to calculate completion
      journal = @question.journal
      submission = journal.journal_submissions.find_or_create_by(user: current_user)
      completion_percentage = submission.completion_percentage
      
      render json: { 
        status: 'success', 
        message: 'Response saved',
        completion_percentage: completion_percentage,
        all_required_answered: submission.all_required_answered?,
        response_id: @response.id
      }
    else
      render json: { status: 'error', errors: @response.errors.full_messages }
    end
  end

  def update
    journal_entry = JournalEntry.find(params[:journal_entry_id]) if params[:journal_entry_id]
    
    if journal_entry
      @response = current_user.responses.find_or_initialize_by(
        question: @question, 
        journal_entry: journal_entry
      )
    else
      @response = current_user.responses.find_or_initialize_by(question: @question)
    end
    
    if @response.persisted?
      if @response.update(response_params)
        # Get journal submission to calculate completion
        journal = @question.journal
        submission = journal.journal_submissions.find_or_create_by(user: current_user)
        completion_percentage = submission.completion_percentage
        
        render json: { 
          status: 'success', 
          message: 'Response updated',
          completion_percentage: completion_percentage,
          all_required_answered: submission.all_required_answered?,
          response_id: @response.id
        }
      else
        render json: { status: 'error', errors: @response.errors.full_messages }
      end
    else
      @response.assign_attributes(response_params)
      @response.journal_entry = journal_entry if journal_entry
      if @response.save
        # Get journal submission to calculate completion
        journal = @question.journal
        submission = journal.journal_submissions.find_or_create_by(user: current_user)
        completion_percentage = submission.completion_percentage
        
        render json: { 
          status: 'success', 
          message: 'Response saved',
          completion_percentage: completion_percentage,
          all_required_answered: submission.all_required_answered?,
          response_id: @response.id
        }
      else
        render json: { status: 'error', errors: @response.errors.full_messages }
      end
    end
  end

  # Mark all feedback for this response as read (for students)
  def mark_feedback_as_read
    @response = Response.find(params[:id])
    
    if current_user == @response.user
      @response.mark_all_feedback_as_read!(current_user)
      render json: { status: 'success', message: 'Feedback marked as read' }
    else
      render json: { status: 'error', message: 'Unauthorized' }, status: :forbidden
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def response_params
    permitted_params = params.require(:response).permit(:content, :journal_entry_id, content: [])
    
    # Handle multiple choice checkboxes - join array into comma-separated string
    if permitted_params[:content].is_a?(Array)
      permitted_params[:content] = permitted_params[:content].reject(&:blank?).join(',')
    end
    
    # Handle file uploads - store filename as content
    if permitted_params[:content].respond_to?(:original_filename)
      # For file uploads, we'll store the filename as content
      # In a real application, you'd want to process and store the file
      permitted_params[:content] = permitted_params[:content].original_filename
    end
    
    permitted_params
  end
end
