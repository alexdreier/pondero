class JournalEntriesController < ApplicationController
  before_action :set_journal
  before_action :set_journal_entry, only: [:show, :edit, :update, :destroy, :submit]
  before_action :authenticate_user!

  def index
    @journal_entries = @journal.journal_entries.for_user(current_user).recent
  end

  def show
    @responses = @journal_entry.responses.includes(:question)
    @completion_percentage = @journal_entry.completion_percentage
  end

  def new
    @journal_entry = @journal.journal_entries.build(
      user: current_user,
      entry_date: Date.current,
      title: "Entry for #{Date.current.strftime('%B %d, %Y')}"
    )
  end

  def create
    @journal_entry = @journal.journal_entries.build(journal_entry_params)
    @journal_entry.user = current_user

    if @journal_entry.save
      redirect_to journal_journal_entry_path(@journal, @journal_entry), 
                  notice: 'Journal entry was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    ensure_can_edit_entry
  end

  def update
    ensure_can_edit_entry
    
    if @journal_entry.update(journal_entry_params)
      redirect_to journal_journal_entry_path(@journal, @journal_entry), 
                  notice: 'Journal entry was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ensure_can_edit_entry
    @journal_entry.destroy
    redirect_to journal_journal_entries_path(@journal), 
                notice: 'Journal entry was successfully deleted.'
  end

  def submit
    ensure_can_edit_entry
    
    if @journal_entry.all_required_answered?
      @journal_entry.submit!
      redirect_to journal_journal_entry_path(@journal, @journal_entry), 
                  notice: 'Journal entry was successfully submitted.'
    else
      redirect_to journal_journal_entry_path(@journal, @journal_entry), 
                  alert: 'Please answer all required questions before submitting.'
    end
  end

  private

  def set_journal
    @journal = Journal.find(params[:journal_id])
  end

  def set_journal_entry
    @journal_entry = @journal.journal_entries.find(params[:id])
  end

  def journal_entry_params
    params.require(:journal_entry).permit(:title, :description, :entry_date)
  end

  def ensure_can_edit_entry
    unless @journal_entry.user == current_user && @journal_entry.draft?
      redirect_to journal_journal_entry_path(@journal, @journal_entry), 
                  alert: 'You cannot edit this journal entry.'
    end
  end
end
