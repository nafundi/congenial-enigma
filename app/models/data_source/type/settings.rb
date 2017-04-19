# This module includes functionality for data source settings. All data source
# types have some attributes in common, for example, name. The attributes that
# vary based on the data source type are stored in the settings JSON attribute.
# Use ::with_settings to define a data source type's supported settings. For
# example:
#
#   with_settings :url, :token
#
# Using ::with_settings adds validations and allows controllers to know which
# parameters to permit. It also adds accessor methods for the settings. For
# example:
#
#   class DataSources::Example < DataSource
#     with_settings :url
#
#     ...
#   end
#
#   source = DataSources::Example.new
#   source.url = 'https://some.url'
#   source.url
#       #=> "https://some.url"
#
# You are responsible for validating the settings you define. When adding an
# error for a setting, add the error to the :settings attribute, then specify
# the full error message.
#
module DataSource::Type::Settings
  extend ActiveSupport::Concern

  included do
    # Avoid accessing this class attribute directly: use ::supported_settings
    # and ::with_settings.
    class_attribute :_settings, instance_accessor: false,
                    instance_predicate: false
    self._settings = Set.new.freeze

    after_initialize :initialize_settings

    before_validation :stringify_settings
    validate :settings_are_json_object
    validate :settings_are_supported
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
      # The settings of the data source class are the same object as the
      # settings of its superclass if and only if the class's settings have not
      # been cloned yet.
      return unless _settings.equal?(superclass._settings)
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

  def initialize_settings
    self.settings ||= {}
  end

  def stringify_settings
    settings.stringify_keys!
  end

  def settings_are_json_object
    errors.add :settings, 'must be a JSON object' unless settings.is_a?(Hash)
  end

  def settings_are_supported
    settings.each do |key, _|
      unless self.class._settings.include?(key)
        errors.add :settings, 'are not all supported'
        return
      end
    end
  end
end
