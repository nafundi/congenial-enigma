class DataProcessor::Odk < DataProcessor::Base
  def process(request)
    return unless valid_content?(request) && valid_form_id?(request)
    request.params['data'].each do |submission|
      process_submission submission: submission, request: request
    end
  end

  protected

  def valid_content?(request)
    valid = request.params['content'] == 'record'
    unless valid
      Rais.logger.debug "Submission(s) not processed: content must be 'record'."
    end
    valid
  end

  def valid_form_id?(request)
    valid = request.params['formId'] == data_source.form_id
    unless valid
      Rails.logger.debug do
        # TODO: Email the user about this case? It probably indicates a
        # configuration error.
        "The form ID of the request, '#{request.params['formId']}', does not match the form ID of the data source, '#{data_source.form_id}'."
      end
    end
    valid
  end

  def process_submission(submission:, request:)
    data_source.alerts.each do |alert|
      test = alert.rule.test(submission)
      if test.success? || test.error?
        # TODO: Update this logic once we start automatically refreshing tokens.
        destination_service = alert.data_destination.configured_service
        if destination_service.safely_connected?
          message = message(request: request, alert: alert, test: test)
          alert.data_destination.messenger.deliver message
        else
          Rails.logger.debug "The message was not delivered, because configured service #{destination_service.id} must be connected or reconnected to Gmail."
        end
      elsif Rails.env.development?
        Rails.logger.debug do
          "No message was sent for the alert with this message:\n\n#{alert.message}"
        end
      end
    end
  end
end
