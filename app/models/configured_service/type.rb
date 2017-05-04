# This module includes functionality for the configured service type, including
# single table inheritance. There is a separate configured service subclass for
# each service technology. Follow these steps to add a new configured service
# type:
#
#   1. Define a class for the configured service type in the ConfiguredServices
#      module, for example, ConfiguredServices::Odk.
#   2. Add the demodulized class name (for example, 'Odk') to TYPE_CLASS_NAMES.
#   3. Provide a human-friendly name for the service technology using
#      ::with_technology_name.
#   4. See ModelAttributes::Settings for ways to store configured service
#      settings.
#
module ConfiguredService::Type
  extend ActiveSupport::Concern

  include ModelAttributes::Type
  include ModelAttributes::Settings
  include ConfiguredService::Type::TechnologyName

  # Whitelist of demodulized names of configured service classes
  TYPE_CLASS_NAMES = %w[Odk].freeze

  class_methods do
    def type_class_names
      TYPE_CLASS_NAMES.map { |name| "ConfiguredServices::#{name}" }
    end
  end
end
