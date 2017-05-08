require 'google/apis/gmail_v1'

class Messenger::Gmail < Messenger::Base
  # TODO: Error handling.
  def deliver(message)
    gmail_message = Google::Apis::GmailV1::Message.new(raw: message.encoded)
    gmail = data_destination.configured_service.gmail
    gmail.send_user_message('me', gmail_message)
  end
end
