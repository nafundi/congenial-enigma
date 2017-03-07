class DataSource < ApplicationRecord
  include DataSource::Type

  before_validation :normalize_name
  validates :name, presence: true

  protected

  def normalize_name
    return if name.nil?
    name.gsub! /\s+/, ' '
    name.strip!
  end
end
