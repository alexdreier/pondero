class ResponsesController < ApplicationController
  before_action :set_question, only: [:create, :update]
  
  def create
    journal_entry = JournalEntry.find(params[:journal_entry_id]) if params[:journal_entry_id]
    @response = current_user.responses.build(response_params)
    @response.question = @question
    @response.journal_entry = journal_entry if journal_entry
    
    if @response.save
      completion_percentage = journal_entry&.completion_percentage || 0
      render json: { 
        status: 'success', 
        message: 'Response saved',
        completion_percentage: completion_percentage
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
        completion_percentage = journal_entry&.completion_percentage || 0
        render json: { 
          status: 'success', 
          message: 'Response updated',
          completion_percentage: completion_percentage
        }
      else
        render json: { status: 'error', errors: @response.errors.full_messages }
      end
    else
      @response.assign_attributes(response_params)
      @response.journal_entry = journal_entry if journal_entry
      if @response.save
        completion_percentage = journal_entry&.completion_percentage || 0
        render json: { 
          status: 'success', 
          message: 'Response saved',
          completion_percentage: completion_percentage
        }
      else
        render json: { status: 'error', errors: @response.errors.full_messages }
      end
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def response_params
    params.require(:response).permit(:content, :journal_entry_id)
  end
end
