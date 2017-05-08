module ServiceProvided
  extend ActiveSupport::Concern

  included do
    belongs_to :configured_service
    validates :configured_service, presence: true
    validate :type_must_match_configured_service
  end

  class_methods do
    # Each data source or data destination class is associated with its own
    # configured service class. #configured_service_class returns that class.
    def configured_service_class
      name = "ConfiguredServices::" + self.name.demodulize
      unless ConfiguredService.type_class_names.include? name
        raise ArgumentError
      end
      name.constantize
    end
  end

  protected

  def type_must_match_configured_service
    return unless configured_service
    unless type.demodulize == configured_service.type.demodulize
      errors.add :type, 'must match the type of the configured service'
    end
  end
end
