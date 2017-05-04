class ConfiguredServicesController < ApplicationController
  before_action :set_service, only: [:edit, :update, :destroy]

  add_breadcrumb 'My Servers', :configured_services_path

  def new
    @service = ConfiguredService.new
    render_new
  end

  def create
    @service = ConfiguredService.new(service_params)
    if @service.save
      redirect_to new_integration_path
    else
      render_new
    end
  end

  def index
    @services = ConfiguredService.order_by_name.load
  end

  def edit
    render_edit
  end

  def update
    if @service.update(service_params)
      redirect_to configured_services_path
    else
      render_edit
    end
  end

  def destroy
    @service.destroy
    redirect_to configured_services_path
  end

  protected

  def set_service
    @service = ConfiguredService.find(params[:id])
  end

  def render_new
    add_breadcrumb 'Add Server'
    render 'new'
  end

  def service_params
    unless ConfiguredService.type_class_names.include? params[:type]
      raise ArgumentError
    end
    service_class = params[:type].constantize
    settings = service_class.supported_settings.map(&:to_sym)
    params.permit(:type, :name, settings: settings)
  end

  def render_edit
    add_breadcrumb @service.name
    render 'edit'
  end
end
