# This module includes functionality for the data source's data processor: see
# DataProcessor::Base. Because data formats vary, each data source type is
# typically associated with its own data processor class.
#
# Use ::with_processor to set the data source type's data processor class.
# Otherwise, it defaults to the data processor with the same demodulized class
# name as the data source. Once the data processor class is set, a data source
# object may instantiate a data processor object using #processor.
#
module DataSource::Type::Processor
  extend ActiveSupport::Concern

  MESSENGER = Messenger::Logger.new

  included do
    # Avoid accessing this class attribute directly: use ::processor_class and
    # ::with_processor.
    class_attribute :_processor, instance_accessor: false,
                    instance_predicate: false
  end

  class_methods do
    def with_processor(processor_class)
      self._processor = processor_class
    end

    def processor_class
      self._processor || "DataProcessor::#{name.demodulize}".constantize
    end
  end

  def processor
    self.class.processor_class.new(data_source: self, messenger: MESSENGER)
  end
end
