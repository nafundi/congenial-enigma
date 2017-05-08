class DataDestination < ApplicationRecord
  include Draftable
  include ModelAttributes::Name
  include ServiceProvided
  include DataDestination::Type

  with_draft_attribute :data_destination_id

  has_many :alerts, dependent: :destroy
end
