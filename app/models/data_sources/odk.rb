class DataSources::Odk < DataSource
  with_settings :form_id
  with_rules [
    ::Rules::Odk::NumericEquality,
    ::Rules::Odk::GreaterThan,
    ::Rules::Odk::LessThan
  ]

  validate :validate_form_id

  alias_method :server, :configured_service

  protected

  def validate_form_id
    message = if !form_id.is_a?(String)
                'Form ID is invalid'
              elsif form_id.blank?
                "Form ID can't be blank"
              end
    errors.add :settings, message unless message.nil?
  end
end
