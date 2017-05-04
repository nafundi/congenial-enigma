# This module includes functionality for accessing the name of the service
# technology.
module ConfiguredService::Type::TechnologyName
  extend ActiveSupport::Concern

  included do
    # Avoid accessing this class attribute directly: use ::technology_name and
    # ::with_technology_name.
    class_attribute :_technology_name, instance_accessor: false,
                    instance_predicate: false
  end

  class_methods do
    def with_technology_name(name)
      self._technology_name = name.dup.freeze
    end

    def technology_name
      _technology_name || name
    end
  end
end
