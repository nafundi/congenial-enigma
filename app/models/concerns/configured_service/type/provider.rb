# This module provides functionality for services that are a data source
# provider and/or a data destination provider. Use ::provides to mark a service
# as a data source provider and/or a data destination provider. Use ::provides?
# to determine whether a service is a data source provider, a data destination
# provider, or both. Examples:
#
#   # We mark the New York Times API as a data source provider.
#   class ConfiguredServices::NyTimes
#     provides :data_source
#
#     ...
#   end
#
#   # We mark Salesforce as both a data source and data destination provider.
#   class ConfiguredServices::Salesforce
#     provides :data_source, :data_destination
#
#     ...
#   end
#
#   ConfiguredServices::NyTimes.provides? :data_source
#       #=> true
#   ConfiguredServices::NyTimes.provides? :data_destination
#       #=> false
#   ConfiguredServices::Salesforce.provides? :data_source
#       #=> true
#   ConfiguredServices::Salesforce.provides? :data_destination
#       #=> true
#
module ConfiguredService::Type::Provider
  extend ActiveSupport::Concern

  included do
    # Avoid accessing this class attribute directly: use ::provides and
    # ::provides?.
    class_attribute :_provider
    self._provider = HashWithIndifferentAccess.new({
      data_source: false,
      data_destination: false
    })

    # All CertifiedService subclasses will have :data_sources and
    # :data_destinations associations, even if they do not provide them.
    # Otherwise, because of the single table inheritance, we would have to give
    # up on recognized bi-directional associations: the :inverse_of option of
    # ::belongs_to and ::has_many does not play well with single table
    # inheritance. However, we override #data_sources and #data_destinations
    # below to raise an error if they are called by an object whose service does
    # not provide them.
    has_many :data_sources, dependent: :destroy
    has_many :data_destinations, dependent: :destroy
  end

  class_methods do
    # If a configured service class is a data source provider and/or a data
    # destination provider, its subclasses must be as well: there is no
    # "unprovide" method.
    def provides(*targets)
      clone_superclass_providers
      targets.each do |target|
        raise ArgumentError unless _provider.key? target
        _provider[target] = true
      end
    end

    def provides?(target)
      _provider.fetch target
    end

    # Asserts that the service is a provider of the specified kind.
    def provides!(target)
      raise "not a #{target} provider" unless provides? target
    end

    # Each service that is a data source provider is associated with its own
    # data source class. #data_source_class returns that class.
    def data_source_class
      provides! :data_source
      name = 'DataSources::' + self.name.demodulize
      raise ArgumentError unless DataSource.type_class_names.include? name
      name.constantize
    end

    # Each service that is a data destination provider is associated with its
    # own data destination class. #data_destination_class returns that class.
    def data_destination_class
      provides! :data_destination
      name = 'DataDestinations::' + self.name.demodulize
      raise ArgumentError unless DataDestination.type_class_names.include? name
      name.constantize
    end

    protected

    def clone_superclass_providers
      # The class's provider settings are the same object as those of its
      # superclass if and only if the class's provider settings have not been
      # cloned yet.
      return unless _provider.equal? superclass._provider
      # The class inherits its superclass's provider settings.
      self._provider = superclass._provider.dup
    end
  end

  def data_sources
    self.class.provides! :data_source
    super
  end

  def data_destinations
    self.class.provides! :data_destination
    super
  end
end
