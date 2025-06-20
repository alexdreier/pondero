class ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme, only: [:show, :edit, :update, :destroy]
  before_action :authorize_theme_management, except: [:index, :show]

  def index
    @themes = Theme.all.order(:name)
  end

  def show
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = Theme.new(theme_params)
    
    if @theme.save
      redirect_to @theme, notice: 'Theme was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @theme.update(theme_params)
      redirect_to @theme, notice: 'Theme was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @theme.destroy
    redirect_to themes_path, notice: 'Theme was successfully deleted.'
  end

  private

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:name, :description, :colors, :fonts, :layout_options)
  end

  def authorize_theme_management
    redirect_to themes_path, alert: 'Access denied.' unless current_user.administrator?
  end
end
