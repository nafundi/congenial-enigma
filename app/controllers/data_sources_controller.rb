class DataSourcesController < ApplicationController
  before_action :set_source, only: [:edit, :update, :destroy, :push]
  skip_before_action :verify_authenticity_token, only: :push

  add_breadcrumb 'Data Sources', :data_sources_path

  def new
    @source = DataSource.new
    render_new
  end

  def create
    @source = DataSource.new(source_params)
    if @source.save
      redirect_to data_sources_path
    else
      render_new
    end
  end

  def index
    @sources = DataSource.order_by_name.load
  end

  def edit
    render_edit
  end

  def update
    if @source.update(source_params)
      redirect_to data_sources_path
    else
      render_edit
    end
  end

  def destroy
    @source.destroy
    redirect_to data_sources_path
  end

  # This is the action for data sources pushing to the app, not for the app
  # itself pushing.
  def push
    # Some data sources stop pushing unless they receive a successful response.
    head 200
  end

  protected

  def set_source
    @source = DataSource.find(params[:id])
  end

  def render_new
    add_breadcrumb 'Add Data Source'
    render 'new'
  end

  def source_params
    raise ArgumentError unless DataSource.type_class_names.include?(params[:type])
    source_class = params[:type].constantize
    settings = source_class.supported_settings.map(&:to_sym)
    params.permit(:type, :name, settings: settings)
  end

  def render_edit
    add_breadcrumb @source.name
    render 'edit'
  end
end
