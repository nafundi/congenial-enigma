# This module includes functionality for a model's `name` attribute.
module ModelAttributes::Name
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_name
    validates :name, presence: true

    scope :order_by_name, -> { reorder(:name) }
  end

  protected

  def normalize_name
    return if name.nil?
    name.gsub! /\s+/, ' '
    name.strip!
  end
end
