class DataDestinationsController < ApplicationController
  include ConfiguredServicePathHelpers

  before_action :set_service
  before_action :set_destination, only: [:edit, :update, :destroy, :push]

  before_action do
    add_configured_service_breadcrumb
    add_breadcrumb @service.name, edit_configured_service_path(@service)
    add_breadcrumb @service.class.terminology.data_destination.pluralize.titleize,
                   configured_service_data_destinations_path(@service)
  end

  def index
    @destinations = @service.data_destinations.order_by_name.load
  end

  def new
    @destination = @service.class.data_destination_class.new
    render_new
  end

  def create
    @destination = DataDestination.new(destination_params)
    if @destination.save
      @destination.save_draft
      redirect_to new_integration_path
    else
      render_new
    end
  end

  def edit
    render_edit
  end

  def update
    if @destination.update(destination_params)
      redirect_to configured_service_data_destinations_path(@service)
    else
      render_edit
    end
  end

  def destroy
    @destination.destroy
    redirect_to configured_service_data_destinations_path(@service)
  end

  protected

  def set_service
    @service = ConfiguredService.find(params[:configured_service_id])
  end

  def set_destination
    @destination = @service.data_destinations.find(params[:id])
  end

  def render_new
    add_breadcrumb 'Add ' + @service.class.terminology.data_destination.titleize
    render 'new'
  end

  def destination_params
    destination_class = @service.class.data_destination_class
    settings = destination_class.supported_settings.map(&:to_sym)
    destination_params = params.permit(:configured_service_id, :name,
                                       settings: settings)
    destination_params[:type] = destination_class.name
    destination_params
  end

  def render_edit
    add_breadcrumb @destination.name
    render 'edit'
  end
end
