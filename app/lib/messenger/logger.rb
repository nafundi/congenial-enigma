class Messenger::Logger < Messenger::Base
  def deliver(message)
    Rails.logger.info message.body
  end
end
