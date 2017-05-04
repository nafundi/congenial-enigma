module ConfiguredService::Type
  extend ActiveSupport::Concern

  include ModelAttributes::Type
  include ModelAttributes::Settings

  # Whitelist of demodulized names of configured service classes
  TYPE_CLASS_NAMES = %w[].freeze

  class_methods do
    def type_class_names
      TYPE_CLASS_NAMES.map { |name| "ConfiguredServices::#{name}" }
    end
  end
end
