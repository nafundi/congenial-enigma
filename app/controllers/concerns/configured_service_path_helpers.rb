module ConfiguredServicePathHelpers
  def add_configured_service_breadcrumb
    if service_class.present?
      breadcrumb = service_class.terminology.service + ' ' +
                   service_class.terminology.configured_service.pluralize.titleize
      add_breadcrumb breadcrumb, typed_configured_services_path
    else
      add_breadcrumb 'My Configured Services', configured_services_path
    end
  end

  def typed_configured_services_path
    raise 'could not determine type' unless service_class
    configured_services_path(type: service_class.name.demodulize)
  end

  protected

  def service_class
    if @service_class.present?
      @service_class
    elsif @service.present?
      @service.class
    else
      nil
    end
  end
end
