class SectionsController < ApplicationController
  before_action :set_journal
  before_action :set_section, only: [:show, :edit, :update, :destroy]
  before_action :ensure_can_manage_journals

  def new
    @section = @journal.sections.build
    @section.position = @journal.sections.count + 1
  end

  def create
    @section = @journal.sections.build(section_params)
    @section.position = @journal.sections.count + 1

    if @section.save
      redirect_to @journal, notice: 'Section was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @section.update(section_params)
      redirect_to @journal, notice: 'Section was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @section.destroy
    redirect_to @journal, notice: 'Section was successfully deleted.'
  end

  def reorder
    positions = params[:positions]
    
    @journal.sections.transaction do
      positions.each do |position_data|
        section = @journal.sections.find(position_data[:id])
        section.update!(position: position_data[:position])
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

  def set_section
    @section = @journal.sections.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:title, :description)
  end

  def ensure_can_manage_journals
    redirect_to root_path, alert: 'Access denied.' unless current_user.can_create_journals?
  end
end
