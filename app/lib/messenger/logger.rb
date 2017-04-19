class Messenger::Logger < Messenger::Base
  def message(text)
    Rails.logger.info text
  end
end
