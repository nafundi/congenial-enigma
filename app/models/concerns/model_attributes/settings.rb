# This module includes functionality for models with a JSON attribute named
# settings. A common use case for the settings attribute is single table
# inheritance, when different subclasses may need to store separate settings.
#
# For example, suppose we are buildng an app that stores information about
# users' pets in a Pet model. The Pet model uses single table inheritance, so
# there are also classes Dog and Horse that extend Pet. All Pet subclasses have
# some attributes in common, for example, name. Other attributes vary based on
# species: we may wish to know whether a Dog can catch and how fast a Horse can
# gallop. Such attributes may be stored in the settings JSON attribute.
# TODO: Should we choose a more generic name than "settings"?
#
# Use ::with_settings to define a class's supported settings. For example:
#
#   with_settings :trot_speed, :gallop_speed
#
# Using ::with_settings adds validations and allows controllers to know which
# parameters to permit. It also adds accessor methods for the settings. For
# example:
#
#   class Pets::Horse < Pet
#     with_settings :trot_speed, :gallop_speed
#
#     ...
#   end
#
#   horse = Pets::Horse.new
#   horse.trot_speed = 8
#   horse.trot_speed
#       #=> 8
#
# You are responsible for validating the settings you define. When adding an
# error for a setting, add the error to the :settings attribute, then specify
# the full error message.
#
# In the migration in which you add the settings attribute, consider adding a
# default value of {} and a not-null constraint. Together, they will help ensure
# that #settings always returns a Hash, not nil.
#
module ModelAttributes::Settings
  extend ActiveSupport::Concern

  included do
    # Avoid accessing this class attribute directly: use ::supported_settings
    # and ::with_settings.
    class_attribute :_settings, instance_accessor: false,
                    instance_predicate: false
    self._settings = Set.new.freeze

    before_validation :stringify_settings
    validate :settings_cannot_be_nil
    validate :settings_must_be_json_object
    validate :settings_must_be_supported
  end

  class_methods do
    def with_settings(*names)
      clone_superclass_settings
      names.each do |name|
        frozen_name = name.to_s.dup.freeze
        setting_accessor frozen_name
        _settings << frozen_name
      end
    end

    def supported_settings
      _settings.to_a
    end

    protected

    def clone_superclass_settings
      # The class's settings are the same object as the settings of its
      # superclass if and only if the class's settings have not been cloned yet.
      return unless _settings.equal? superclass._settings
      # The class inherits its superclass's supported settings.
      self._settings = superclass._settings.dup
    end

    def setting_reader(name)
      define_method(name) { settings[name] }
    end

    def setting_writer(name)
      define_method("#{name}=") { |value| settings[name] = value }
    end

    def setting_accessor(name)
      setting_reader name
      setting_writer name
    end
  end

  protected

  def stringify_settings
    return if settings.nil? || !settings.is_a?(Hash)
    settings.stringify_keys!
  end

  def settings_cannot_be_nil
    errors.add :settings, 'Settings must be defined' if settings.nil?
  end

  def settings_must_be_json_object
    unless settings.nil? || settings.is_a?(Hash)
      errors.add :settings, 'Settings must be a JSON object'
    end
  end

  def settings_must_be_supported
    return if settings.nil? || !settings.is_a?(Hash)
    settings.each_key do |key|
      unless self.class._settings.include?(key)
        errors.add :settings, 'Settings are not all supported'
        return
      end
    end
  end
end
