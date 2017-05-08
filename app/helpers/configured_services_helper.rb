module ConfiguredServicesHelper
  def render_fields
    render @service_class.name.demodulize.underscore + '_fields'
  end
end
