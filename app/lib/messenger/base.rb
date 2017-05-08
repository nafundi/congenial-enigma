class Messenger::Base
  attr_reader :data_destination

  def initialize(data_destination)
    @data_destination = data_destination
  end

  # Sends, delivers, or outputs a Mail::Message object.
  def deliver(message)
    raise NotImplementedError
  end
end
