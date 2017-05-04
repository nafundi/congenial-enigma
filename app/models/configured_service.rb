class ConfiguredService < ApplicationRecord
  include ModelAttributes::Name
  include ConfiguredService::Type

  has_many :data_sources, dependent: :destroy
end
