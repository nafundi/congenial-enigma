class Messenger::Base
  # Sends, delivers, or outputs a Mail::Message object.
  def message(message)
    raise NotImplementedError
  end
end
