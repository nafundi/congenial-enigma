class DataSource < ApplicationRecord
  include ModelAttributes::Name
  include DataSource::Type

  belongs_to :configured_service
  validates :configured_service, presence: true

  has_many :data_source_alerts
  has_many :alerts, through: :data_source_alerts
  before_destroy :destroy_alerts

  protected

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
