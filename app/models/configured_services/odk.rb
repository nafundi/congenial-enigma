class ConfiguredServices::Odk < ConfiguredService
  include Draftable

  provides :data_source
  with_terminology service: 'ODK Aggregate', configured_service: 'server',
                   data_source: 'form'
  with_draft_attribute :data_source_configured_service_id

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
