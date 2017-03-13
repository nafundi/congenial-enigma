class Messenger::Base
  def message(text)
    raise NotImplementedError
  end
end
