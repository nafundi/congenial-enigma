class DataDestination < ApplicationRecord
  include ModelAttributes::Name
  include ServiceProvided
  include DataDestination::Type

  has_many :alerts, dependent: :destroy
end
