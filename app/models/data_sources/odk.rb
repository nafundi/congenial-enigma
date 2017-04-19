class DataSources::Odk < DataSource
  with_type_title 'ODK Aggregate'
  with_settings :url
  with_rules [
    ::Rules::Odk::NumericEquality,
    ::Rules::Odk::GreaterThan,
    ::Rules::Odk::LessThan
  ]

  validate :validate_url

  protected

  def validate_url
    message = if !url.is_a?(String)
                'URL is invalid'
              elsif url.blank?
                "URL can't be blank"
              end
    errors.add :settings, message unless message.nil?
  end
end
