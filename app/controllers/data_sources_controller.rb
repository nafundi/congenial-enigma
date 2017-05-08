class DataSourcesController < ApplicationController
  include ConfiguredServicePathHelpers

  before_action :set_service
  before_action :set_source, only: [:edit, :update, :destroy, :push]
  skip_before_action :verify_authenticity_token, only: :push

  before_action do
    add_configured_service_breadcrumb
    add_breadcrumb @service.name, edit_configured_service_path(@service)
    add_breadcrumb @service.class.terminology.data_source.pluralize.titleize,
                   configured_service_data_sources_path(@service)
  end

  def index
    @sources = @service.data_sources.order_by_name.load
  end

  def new
    @source = @service.class.data_source_class.new
    render_new
  end

  def create
    @source = DataSource.new(source_params)
    if @source.save
      redirect_to new_integration_path
    else
      render_new
    end
  end

  def edit
    render_edit
  end

  def update
    if @source.update(source_params)
      redirect_to configured_service_data_sources_path(@service)
    else
      render_edit
    end
  end

  def destroy
    @source.destroy
    redirect_to configured_service_data_sources_path(@service)
  end

  # This is the action for data sources pushing to the app, not for the app
  # itself pushing.
  def push
    # Some data sources stop pushing unless they receive a successful response,
    # so #push should never raise an error.
    begin
      @source.processor.process request
    rescue => e
      Rails.logger.error e.backtrace.join("\n")
    end
    head 200
  end

  protected

  def set_service
    @service = ConfiguredService.find(params[:configured_service_id])
  end

  def set_source
    @source = @service.data_sources.find(params[:id])
  end

  def render_new
    add_breadcrumb 'Add ' + @service.class.terminology.data_source.titleize
    render 'new'
  end

  def source_params
    source_class = @service.class.data_source_class
    settings = source_class.supported_settings.map(&:to_sym)
    source_params = params.permit(:configured_service_id, :name,
                                  settings: settings)
    source_params[:type] = source_class.name
    source_params
  end

  def render_edit
    add_breadcrumb @source.name
    render 'edit'
  end
end
