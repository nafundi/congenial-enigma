class DataProcessorMailer < ApplicationMailer
  include DataProcessorsHelper
  helper DataProcessorsHelper

  def odk(**args)
    prepare_mail **args
    locals[:form] = data_source
    from = data_destination.configured_service.email_address
    if test.success?
      to = data_destination.emails
      subject = 'Incoming data triggered an alert'
    else
      to = from
      subject = 'Error from incoming data'
    end
    mail(from: from, to: to, subject: subject)
  end

  protected

  def set_locals(locals)
    @locals = if locals.nil?
                HashWithIndifferentAccess.new
              elsif locals.is_a? HashWithIndifferentAccess
                self
              else
                locals.with_indifferent_access
              end
  end

  def prepare_mail(request:, processor:, alert:, test:, locals: nil)
    raise ArgumentError unless request && processor && alert && test
    @request = request
    @processor = processor
    @alert = alert
    raise 'invalid test' unless test.success? || test.error?
    @test = test
    set_locals locals
  end
end
