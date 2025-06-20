class QuestionsController < ApplicationController
  before_action :set_journal
  before_action :set_question, only: [:edit, :update, :destroy]
  before_action :ensure_can_manage_journals

  def new
    @question = @journal.questions.build
    @question.position = @journal.questions.count + 1
    @sections = @journal.sections.ordered
    
    # Set section if provided
    if params[:section_id].present?
      @question.section_id = params[:section_id]
    end
  end

  def create
    @question = @journal.questions.build(question_params)
    @question.position = @journal.questions.count + 1

    if @question.save
      redirect_to @journal, notice: 'Question was successfully added.'
    else
      @sections = @journal.sections.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @sections = @journal.sections.ordered
  end

  def update
    if @question.update(question_params)
      redirect_to @journal, notice: 'Question was successfully updated.'
    else
      @sections = @journal.sections.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    redirect_to @journal, notice: 'Question was successfully deleted.'
  end

  def reorder
    positions = params[:positions]
    
    @journal.questions.transaction do
      positions.each do |position_data|
        question = @journal.questions.find(position_data[:id])
        question.update!(position: position_data[:position])
      end
    end
    
    render json: { status: 'success' }
  rescue => e
    render json: { status: 'error', message: e.message }
  end

  private

  def set_journal
    @journal = Journal.find(params[:journal_id])
  end

  def set_question
    @question = @journal.questions.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:content, :description, :question_type, :required, :position, :section_id, options_array: [])
  end

  def ensure_can_manage_journals
    redirect_to root_path, alert: 'Access denied.' unless current_user.can_create_journals?
  end
end
