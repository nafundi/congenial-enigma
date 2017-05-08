class ConfiguredServicesController < ApplicationController
  include ConfiguredServicePathHelpers

  before_action :set_service, only: [:edit, :update, :destroy]
  before_action :set_service_class
  before_action :add_configured_service_breadcrumb,
                except: [:create, :update, :destroy]

  def index
    # If there is no valid :type parameter, show all configured services.
    @service_class ||= ConfiguredService
    @services = @service_class.order_by_name.load
  end

  def new
    @service = @service_class.new
    render_new
  end

  def create
    @service = @service_class.new(service_params)
    if @service.save
      if @service_class.oauthable?
        # We still need the user to authenticate the configured service.
        redirect_to edit_configured_service_path(@service)
      else
        redirect_to new_integration_path
      end
    else
      render_new
    end
  end

  def edit
    render_edit
  end

  def update
    if @service.update(service_params)
      redirect_to typed_configured_services_path
    else
      render_edit
    end
  end

  def destroy
    @service.destroy
    redirect_to typed_configured_services_path
  end

  protected

  def set_service
    @service = ConfiguredService.find(params[:id])
  end

  # Sets @service_class to the ConfiguredService subclass whose demodulized name
  # equals params[:type]. If there is no such class, the user is redirected to
  # #index, which will list all configured services regardless of type.
  def set_service_class
    if @service.present?
      @service_class = @service.class
    else
      if !params[:type].is_a?(String)
        is_valid = false
      else
        type = 'ConfiguredServices::' + params[:type]
        is_valid = ConfiguredService.type_class_names.include?(type)
      end
      if is_valid
        @service_class = type.constantize
      elsif action_name != 'index'
        redirect_to configured_services_path
      end
    end
  end

  def render_new
    add_breadcrumb 'Add ' +
                   @service_class.terminology.configured_service.titleize
    render 'new'
  end

  def service_params
    settings = @service_class.supported_settings.map(&:to_sym)
    params.permit(:name, settings: settings)
  end

  def render_edit
    add_breadcrumb @service.name
    render 'edit'
  end
end
