class DataSourceAlert < ApplicationRecord
  belongs_to :data_source
  belongs_to :alert

  validates :data_source_id, presence: true
  validates :alert_id, presence: true
end
