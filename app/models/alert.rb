class Alert < ApplicationRecord
  has_many :data_source_alerts, dependent: :destroy
  has_many :data_sources, through: :data_source_alerts

  validate :rule_must_be_supported
  validate :rule_must_instantiate

  validates :email, presence: true
  validates :message, presence: true

  # #create_for_data_source is similar to #create, but it also creates a
  # DataSourceAlert record to associate the new alert with a data source. The
  # two creations are wrapped in a transaction, so neither object is created
  # unless both are. Specify the same arguments as for #create, but also specify
  # a data_source_id as part of the attributes Hash. Like #create,
  # #create_for_data_source returns the Alert object regardless of whether it
  # was successfully saved to the database.
  def self.create_for_data_source(attributes, &block)
    attributes = attributes.dup
    source_id = attributes.delete(:data_source_id)
    raise ArgumentError unless source_id

    alert = nil
    ActiveRecord::Base.transaction do
      alert = Alert.new(attributes, &block)
      if alert.save
        data_source_alert = DataSourceAlert.create(
          data_source_id: source_id,
          alert_id: alert.id
        )
        raise ActiveRecord::Rollback unless data_source_alert.persisted?
      end
    end
    alert
  end

  # Returns the cached rule.
  def rule
    @rule ||= reload_rule
  end

  # Resets the rule.
  def reload_rule
    @rule = rule_type.constantize.new(**rule_data.symbolize_keys)
  end

  protected

  # #rule_must_be_supported validates that the rule type is supported by each of
  # the alert's data sources. It implicitly validates that rule_type is the name
  # of a Rule::Base subclass.
  def rule_must_be_supported
    data_sources.distinct.pluck(:type).each do |source_type|
      supported_rules = source_type.constantize.supported_rules
      if supported_rules.none? { |rule_class| rule_class.name == rule_type }
        errors.add :rule_type, "is not supported by one or more of the alert's data sources"
        return
      end
    end
  end

  def rule_must_instantiate
    begin
      reload_rule
    rescue => e
      Rails.logger.error e.backtrace.join("\n")
      errors.add :base, 'Invalid rule'
    end
  end
end
