# DataProcessor::Base encapsulates a "data processor," whose core responsibility
# is to process incoming data and forward it to its next destination.
#
# More precisely, a data processor parses and iterates over incoming data from a
# data source, evaulating it against the rules of the data source's alerts. For
# each matching rule, the data processor triggers a message. Because data
# formats vary, each data source type is typically associated with its own data
# processor class.
#
# To add a new data processor class, extend DataProcessor::Base and override
# #process.
#
class DataProcessor::Base
  attr_reader :data_source

  def initialize(data_source)
    @data_source = data_source
  end

  # #process processes incoming data after receiving an ActionDispatch::Request
  # object from the controller.
  def process(request)
    raise NotImplementedError
  end

  protected

  def message(**args)
    DataProcessorMailer.public_send(self.class.name.demodulize.underscore,
      request: args.delete(:request),
      processor: self,
      alert: args.delete(:alert),
      test: args.delete(:test),
      locals: args
    )
  end
end
