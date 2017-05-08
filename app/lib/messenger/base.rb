class Messenger::Base
  # Sends, delivers, or outputs a Mail::Message object.
  def deliver(message)
    raise NotImplementedError
  end
end
