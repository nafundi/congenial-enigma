class Messenger::Logger < Messenger::Base
  def message(message)
    Rails.logger.info message.body
  end
end
