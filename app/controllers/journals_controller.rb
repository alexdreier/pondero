class JournalsController < ApplicationController
  before_action :set_journal, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :export_pdf, :copy, :create_from_template, :assign_canvas_course, :remove_canvas_assignment]
  before_action :ensure_can_manage_journals, except: [:index, :show, :export_pdf, :templates]

  def index
    if current_user.learner?
      # Show available journals for learners based on visibility
      @journals = Journal.published.where(visibility: ['public_access', 'unlisted'])
    elsif current_user.administrator?
      # Administrators can see ALL journals in the system
      @journals = Journal.includes(:theme, :questions, :user).order(created_at: :desc)
    else
      # Instructors see only their own journals
      @journals = current_user.journals.includes(:theme, :questions)
    end
  end

  def show
    # Debug logging
    Rails.logger.info "=== JOURNAL SHOW DEBUG ==="
    Rails.logger.info "Journal ID: #{@journal.id}"
    Rails.logger.info "Journal Title: #{@journal.title}"
    Rails.logger.info "Journal visibility: #{@journal.visibility}"
    Rails.logger.info "Journal access_level: #{@journal.access_level}"
    Rails.logger.info "Journal published: #{@journal.published?}"
    Rails.logger.info "Current User: #{current_user&.email} (#{current_user&.role})"
    Rails.logger.info "visible_to?(user): #{@journal.visible_to?(current_user)}"
    Rails.logger.info "Accessible: #{@journal.accessible_to?(current_user)}"
    Rails.logger.info "=========================="
    
    # Check if user can access this journal
    unless @journal.accessible_to?(current_user)
      Rails.logger.info "REDIRECTING: User does not have access"
      redirect_to journals_path, alert: 'You do not have access to this journal.'
      return
    end
    
    if current_user.learner?
      # Check if user can respond to this journal
      if @journal.can_respond?(current_user)
        # Find or create submission for this learner
        @submission = @journal.journal_submissions.find_or_create_by(user: current_user)
        @responses = current_user.responses.joins(:question).where(questions: { journal: @journal })
      else
        # Read-only access
        @submission = @journal.journal_submissions.find_by(user: current_user)
        @responses = current_user.responses.joins(:question).where(questions: { journal: @journal }) if @submission
        @read_only = true
      end
    else
      # Show journal details for instructors/admins
      @submissions = @journal.journal_submissions.includes(:user, :comments)
    end
  end

  def new
    @journal = current_user.journals.build
    @themes = Theme.all
  end

  def create
    @journal = current_user.journals.build(journal_params)
    
    # Set position to the next available position
    max_position = current_user.journals.maximum(:position) || 0
    @journal.position = max_position + 1

    if @journal.save
      redirect_to @journal, notice: 'Journal was successfully created.'
    else
      @themes = Theme.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @themes = Theme.all
  end

  def update
    if @journal.update(journal_params)
      redirect_to @journal, notice: 'Journal was successfully updated.'
    else
      @themes = Theme.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @journal.destroy
    redirect_to journals_url, notice: 'Journal was successfully deleted.'
  end

  def publish
    @journal.update(published: true, status: 'published')
    redirect_to @journal, notice: 'Journal has been published.'
  end

  def unpublish
    @journal.update(published: false, status: 'draft')
    redirect_to @journal, notice: 'Journal has been unpublished.'
  end

  def export_pdf
    if current_user.learner?
      # Export learner's own responses
      @submission = @journal.journal_submissions.find_by(user: current_user)
      @responses = current_user.responses.joins(:question).where(questions: { journal: @journal }).includes(:question)
      
      respond_to do |format|
        format.pdf do
          render pdf: "#{@journal.title}_#{current_user.display_name}",
                 template: 'journals/export_pdf',
                 layout: 'pdf',
                 page_size: 'A4',
                 margin: { top: 20, bottom: 20, left: 20, right: 20 }
        end
      end
    else
      # Export all submissions for instructors
      @submissions = @journal.journal_submissions.includes(:user, :comments)
      
      respond_to do |format|
        format.pdf do
          render pdf: "#{@journal.title}_all_submissions",
                 template: 'journals/export_all_pdf',
                 layout: 'pdf',
                 page_size: 'A4',
                 margin: { top: 20, bottom: 20, left: 20, right: 20 }
        end
      end
    end
  end

  def templates
    @template_journals = Journal.where(published: true, status: 'published')
                                .where.not(user: current_user)
                                .includes(:questions, :user)
    @my_journals = current_user.journals.includes(:questions)
  end

  def copy
    begin
      new_journal = @journal.copy_for_user(current_user)
      redirect_to new_journal, notice: 'Journal has been successfully copied.'
    rescue => e
      redirect_to @journal, alert: "Failed to copy journal: #{e.message}"
    end
  end

  def create_from_template
    template_journal = Journal.find(params[:template_id])
    custom_title = params[:title].presence || "New Journal from #{template_journal.title}"
    
    begin
      new_journal = template_journal.copy_for_user(current_user, custom_title)
      redirect_to new_journal, notice: 'Journal has been successfully created from template.'
    rescue => e
      redirect_to templates_journals_path, alert: "Failed to create journal from template: #{e.message}"
    end
  end

  def assign_canvas_course
    unless current_user.administrator?
      redirect_to @journal, alert: 'Only administrators can assign journals to Canvas courses.'
      return
    end
    
    course_id = params[:canvas_course_id]
    course_url = params[:canvas_course_url]
    course_name = params[:canvas_course_name]
    
    if @journal.assign_to_canvas_course(course_id, course_url, course_name)
      redirect_to @journal, notice: 'Journal has been successfully assigned to Canvas course.'
    else
      redirect_to @journal, alert: 'Failed to assign journal to Canvas course. Please check the information provided.'
    end
  end

  def remove_canvas_assignment
    unless current_user.administrator?
      redirect_to @journal, alert: 'Only administrators can remove Canvas course assignments.'
      return
    end
    
    if @journal.remove_canvas_assignment
      redirect_to @journal, notice: 'Canvas course assignment has been removed.'
    else
      redirect_to @journal, alert: 'Failed to remove Canvas course assignment.'
    end
  end

  private

  def set_journal
    Rails.logger.info "=== SET_JOURNAL DEBUG ==="
    Rails.logger.info "Finding journal with ID: #{params[:id]}"
    @journal = Journal.find(params[:id])
    Rails.logger.info "Found journal: #{@journal.title}"
    Rails.logger.info "========================"
  end

  def journal_params
    params.require(:journal).permit(:title, :description, :theme_id, :available_from, :available_until, :visibility, :access_level, :canvas_course_id, :canvas_course_url, :canvas_course_name, :lti_enabled)
  end

  def ensure_can_manage_journals
    redirect_to root_path, alert: 'Access denied.' unless current_user.can_create_journals?
  end
end
