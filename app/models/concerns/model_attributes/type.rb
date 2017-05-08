# This module supplements single-table inheritance by including additional
# functionality for the type attribute. Key additions include:
#
#   1. The type attribute must have a value, which is validated against a
#      whitelist. The including class must define a class method named
#      ::type_class_names that returns this whitelist as an Enumerable of String
#      objects.
#   2. Once persisted, the type attribute cannot change.
#
module ModelAttributes::Type
  extend ActiveSupport::Concern

  class_methods do
    def type_classes
      type_class_names.map(&:constantize)
    end
  end

  included do
    validate :type_must_be_in_whitelist
    validate :type_cannot_change
  end

  protected

  # #type_must_be_in_whitelist is almost exactly the same as this inclusion
  # validation:
  #
  #   validates :type, inclusion: { in: type_class_names }
  #
  # However, while the inclusion validation evaluates ::type_class_names
  # eagerly, #type_must_be_in_whitelist does so lazily. This is necessary,
  # because most including classes will define ::type_class_names after
  # including ModelAttributes::Type, meaning the eager evaluation would attempt
  # to evaluate the method before it is defined.
  #
  def type_must_be_in_whitelist
    unless self.class.type_class_names.include? type
      errors.add :type, 'is not included in the list'
    end
  end

  def type_cannot_change
    errors.add :type, 'cannot change' if persisted? && type_changed?
  end
end
