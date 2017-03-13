class DataProcessor::Odk < DataProcessor::Base
  def process(request)
    return unless request.params['content'] == 'record'
    request.params['data'].each do |submission|
      process_submission submission: submission, request: request
    end
  end

  protected

  def process_submission(submission:, request:)
    data_source.alerts.each do |alert|
      test = alert.rule.test(submission)
      if test.success? || test.error?
        message = message(request: request, alert: alert, test: test,
                          form_id: request.params['formId'])
        messenger.message message.text
      elsif Rails.env.development?
        Rails.logger.debug do
          "No message was sent for the alert with this message:\n\n#{alert.message}"
        end
      end
    end
  end
end
