class ConfiguredServices::Odk < ConfiguredService
  provides :data_source
  with_terminology service: 'ODK Aggregate', configured_service: 'server',
                   data_source: 'form'

  with_settings :url
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
