class DataSource < ApplicationRecord
  include DataSource::Type

  before_validation :normalize_name
  validates :name, presence: true

  scope :order_by_name, -> { reorder(:name) }

  protected

  def normalize_name
    return if name.nil?
    name.gsub! /\s+/, ' '
    name.strip!
  end
end
