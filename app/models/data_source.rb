class DataSource < ApplicationRecord
  include DataSource::Type

  has_many :data_source_alerts
  has_many :alerts, through: :data_source_alerts

  before_validation :normalize_name
  validates :name, presence: true

  before_destroy :destroy_alerts

  scope :order_by_name, -> { reorder(:name) }

  protected

  def normalize_name
    return if name.nil?
    name.gsub! /\s+/, ' '
    name.strip!
  end

  def destroy_alerts
    multi_source_alerts = DataSourceAlert
                            .group(:alert_id)
                            .having('bool_or(data_source_id = ?)', id)
                            .having('count(*) > 1')
    # TODO: Develop an approach for destroying multi-source alerts.
    return false if multi_source_alerts.any?
    alerts.destroy_all
  end
end
