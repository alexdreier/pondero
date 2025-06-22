class ResponseFeedbacksController < ApplicationController
  before_action :set_response
  before_action :set_response_feedback, only: [:update, :destroy]
  before_action :ensure_can_give_feedback, only: [:create]
  before_action :ensure_can_modify_feedback, only: [:update, :destroy]
  
  def create
    @response_feedback = @response.response_feedbacks.build(feedback_params)
    @response_feedback.user = current_user
    
    if @response_feedback.save
      if params[:parent_id].present?
        # This is a reply
        render json: { 
          status: 'success', 
          message: 'Reply added successfully',
          feedback: render_feedback(@response_feedback)
        }
      else
        # This is initial feedback
        render json: { 
          status: 'success', 
          message: 'Feedback added successfully',
          feedback: render_feedback(@response_feedback),
          feedback_count: @response.reload.feedback_count
        }
      end
    else
      render json: { 
        status: 'error', 
        errors: @response_feedback.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def update
    if @response_feedback.update(feedback_params.except(:parent_id))
      render json: { 
        status: 'success', 
        message: 'Feedback updated successfully',
        feedback: render_feedback(@response_feedback)
      }
    else
      render json: { 
        status: 'error', 
        errors: @response_feedback.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def destroy
    # Only allow deletion within 15 minutes of creation for instructors
    # Or admin can delete anytime
    if current_user.administrator? || (@response_feedback.created_at > 15.minutes.ago && @response_feedback.user == current_user)
      @response_feedback.destroy
      render json: { 
        status: 'success', 
        message: 'Feedback deleted successfully',
        feedback_count: @response.reload.feedback_count
      }
    else
      render json: { 
        status: 'error', 
        message: 'Cannot delete feedback after 15 minutes'
      }, status: :forbidden
    end
  end

  private

  def set_response
    @response = Response.find(params[:response_id])
  end

  def set_response_feedback
    @response_feedback = @response.response_feedbacks.find(params[:id])
  end

  def feedback_params
    params.require(:response_feedback).permit(:content, :parent_id)
  end

  def ensure_can_give_feedback
    unless @response.can_receive_feedback?(current_user)
      render json: { 
        status: 'error', 
        message: 'You cannot provide feedback on this response' 
      }, status: :forbidden
    end
  end

  def ensure_can_modify_feedback
    unless can_modify_feedback?
      render json: { 
        status: 'error', 
        message: 'You cannot modify this feedback' 
      }, status: :forbidden
    end
  end

  def can_modify_feedback?
    # Admin can modify anything
    return true if current_user.administrator?
    
    # Users can only modify their own feedback
    @response_feedback.user == current_user
  end
  
  def render_feedback(feedback)
    {
      id: feedback.id,
      content: feedback.content,
      user_name: feedback.user.display_name,
      user_role: feedback.user.role,
      created_at: feedback.created_at.strftime('%B %d, %Y at %I:%M %p'),
      from_student: feedback.from_student?,
      parent_id: feedback.parent_id,
      can_edit: can_modify_feedback?,
      can_delete: (current_user.administrator? || (feedback.created_at > 15.minutes.ago && feedback.user == current_user))
    }
  end
end
