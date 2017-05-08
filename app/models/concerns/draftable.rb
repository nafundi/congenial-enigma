module Draftable
  extend ActiveSupport::Concern

  included do
    class_attribute :_draft_attribute, instance_accessor: false,
                    instance_predicate: false
    after_destroy :destroy_draft
  end

  class_methods do
    def with_draft_attribute(name)
      raise ArgumentError unless AlertDraft::ATTRIBUTES.include? name.to_sym
      self._draft_attribute = name.to_sym
    end

    def draft_attribute
      _draft_attribute
    end
  end

  def save_draft
    Alert.draft.dependably_update(self.class.draft_attribute => id)
  end

  protected

  def destroy_draft
    draft = AlertDraft.first
    return if draft.nil?
    draft.destroy if draft[self.class.draft_attribute] == id
  end
end
