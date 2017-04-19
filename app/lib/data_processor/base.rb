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
  attr_reader :data_source, :messenger

  def initialize(data_source:, messenger:)
    @data_source = data_source
    @messenger = messenger
  end

  # #process processes incoming data after receiving an ActionDispatch::Request
  # object from the controller.
  def process(request)
    raise NotImplementedError
  end

  protected

  def message(**args)
    Message.new(
      request: args.delete(:request),
      processor: self,
      alert: args.delete(:alert),
      test: args.delete(:test),
      locals: args
    )
  end

  # The Message class encapsulates a message that an alert triggers as a data
  # processor processes incoming data. Message text is evaluated as ERB, and
  # arbitrary local variables may be passed to the message for convenient access
  # from the ERB.
  class Message
    include Rails.application.routes.url_helpers

    attr_reader :request, :processor, :alert, :test, :locals

    delegate :data_source, to: :processor

    def initialize(request:, processor:, alert:, test:, locals: nil)
      raise ArgumentError unless request && processor && alert && test
      @request = request
      @processor = processor
      @alert = alert
      @test = test
      @locals = locals ? HashWithIndifferentAccess.new(locals) : nil
    end

    def text
      ERB.new(template).result(binding)
    end

    protected

    # Returns the ERB template.
    def template
      basename = processor.class.name.demodulize.underscore + '.text.erb'
      path = Rails.root.join('app', 'views', 'data_processors', basename).to_path
      File.read(path)
    end

    def default_url_options
      {
        protocol: request.protocol,
        host: request.host,
        port: request.port
      }
    end

    # The ERB may access local variables through the locals Hash or as a method.
    # For example, for locals = { x: 1 }, the ERB may include <%= locals[:x] %>
    # or simply <%= x %>.
    def method_missing(symbol, *args)
      if locals&.key?(symbol)
        raise ArgumentError if args.any? || block_given?
        locals[symbol]
      else
        super
      end
    end
  end
end
