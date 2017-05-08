module DataProcessorsHelper
  attr_reader :request, :processor, :alert, :test, :locals

  delegate :data_source, to: :processor
  delegate :data_destination, to: :alert

  def url_options
    {
      protocol: request.protocol,
      host: request.host,
      port: request.port
    }
  end

  # The ERB may access local variables through the locals Hash or as a method.
  # For example, for locals = { x: 1 }, the ERB may include <%= locals[:x] %>
  # or simply <%= x %>.
  def method_missing(symbol, *args, &block)
    if locals.key? symbol
      raise ArgumentError if args.any? || block_given?
      locals[symbol]
    else
      super
    end
  end
end
