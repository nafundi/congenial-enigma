# This module includes functionality for accessing the data source type's title.
module DataSource::Type::Title
  extend ActiveSupport::Concern

  included do
    # Avoid accessing this class attribute directly: use ::type_title and
    # ::with_type_title.
    class_attribute :_type_title, instance_accessor: false,
                    instance_predicate: false
  end

  class_methods do
    def with_type_title(title)
      self._type_title = title.dup.freeze
    end

    def type_title
      _type_title || name
    end
  end
end
