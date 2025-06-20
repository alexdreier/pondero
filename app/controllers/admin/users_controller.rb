class Admin::UsersController < ApplicationController
  before_action :ensure_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.includes(:journals, :journal_submissions)
                 .order(:created_at)
    
    # Filter by role if specified
    if params[:role].present?
      @users = @users.where(role: params[:role])
    end
    
    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    @users = @users.page(params[:page]).per(20) if defined?(Kaminari)
  end

  def show
    @journals_created = @user.journals.count
    @submissions_count = @user.journal_submissions.count
    @recent_activity = @user.journal_submissions.includes(:journal)
                           .order(updated_at: :desc)
                           .limit(5)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: 'You cannot delete your own account.'
      return
    end
    
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  def export
    @users = User.includes(:journals, :journal_submissions).order(:created_at)
    
    respond_to do |format|
      format.csv do
        send_data generate_csv(@users), filename: "users_export_#{Date.current}.csv"
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role)
  end

  def ensure_admin
    unless current_user&.administrator?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  def generate_csv(users)
    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'Name', 'Email', 'Role', 'Journals Created', 'Submissions', 'Created At', 'Last Sign In']
      
      users.each do |user|
        csv << [
          user.id,
          user.display_name,
          user.email,
          user.role&.humanize || 'Not Set',
          user.journals.count,
          user.journal_submissions.count,
          user.created_at.strftime('%Y-%m-%d'),
          user.current_sign_in_at&.strftime('%Y-%m-%d %H:%M') || 'Never'
        ]
      end
    end
  end
end
