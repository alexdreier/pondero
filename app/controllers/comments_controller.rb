class CommentsController < ApplicationController
  before_action :set_journal_submission
  before_action :set_comment, only: [:destroy]
  before_action :ensure_can_comment, only: [:create]
  before_action :ensure_can_delete_comment, only: [:destroy]

  def create
    @comment = @journal_submission.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @journal_submission, notice: 'Comment added successfully.'
    else
      redirect_to @journal_submission, alert: 'Unable to add comment.'
    end
  end

  def destroy
    @comment.destroy
    redirect_to @journal_submission, notice: 'Comment deleted.'
  end

  private

  def set_journal_submission
    @journal_submission = JournalSubmission.find(params[:journal_submission_id])
  end

  def set_comment
    @comment = @journal_submission.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def ensure_can_comment
    unless current_user.instructor? || current_user.administrator?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def ensure_can_delete_comment
    unless @comment.user == current_user || current_user.administrator?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end
