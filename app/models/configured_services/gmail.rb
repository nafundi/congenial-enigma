require 'googleauth'
require 'google/api_client/client_secrets'
require 'google/apis/gmail_v1'

class ConfiguredServices::Gmail < ConfiguredService
  with_technology_name 'Gmail'
  provides :data_destination
  oauthable

  TOKEN_STATUSES = %i[never_connected safely_connected almost_disconnected
                      disconnected].freeze

  class Authorization
    OAUTH_SCOPES = [
      # We request this for access to the user's email address.
      'https://www.googleapis.com/auth/gmail.metadata',
      'https://www.googleapis.com/auth/gmail.send'
    ].freeze

    def client
      client = client_secrets.to_authorization
      client.scope = OAUTH_SCOPES
      client.redirect_uri = client_secrets.redirect_uris.first
      client
    end

    def authorization_uri(configured_service)
      client = self.client
      raise "ConfiguredService#id can't be blank" if configured_service.id.nil?
      client.state = configured_service.id
      client.additional_parameters = {
        'access_type' => 'offline',
        'include_granted_scopes' => 'true'
      }
      client.authorization_uri.to_s
    end

    def user_authorizer
      @user_authorizer ||= begin
        client_id = Google::Auth::ClientId.from_hash(client_secrets.to_hash)
        Google::Auth::UserAuthorizer.new(client_id, OAUTH_SCOPES,
                                         OauthToken.google_token_store)
      end
    end

    protected

    def client_secrets
      @client_secrets ||= begin
        options = ActiveSupport::JSON.decode(ENV.fetch('GOOGLE_CLIENT_SECRETS'))
        Google::APIClient::ClientSecrets.new(options)
      end
    end
  end

  class_attribute :authorization, instance_accessor: false,
                  instance_predicate: false
  self.authorization = Authorization.new

  def self.authorization=(authorization)
    raise NotImplementedError
  end

  def authorization_uri
    self.class.authorization.authorization_uri(self)
  end

  def token_status
    if oauth_token.nil?
      :never_connected
    else
      seconds = oauth_token.seconds_to_expiration
      if seconds == 0
        :disconnected
      elsif seconds < 60
        :almost_disconnected
      else
        :safely_connected
      end
    end
  end

  TOKEN_STATUSES.each do |status|
    define_method("#{status}?") { token_status == status }
  end

  def gmail
    service = Google::Apis::GmailV1::GmailService.new
    application_name = Rails.application.class.parent_name.titleize
    service.client_options.application_name = application_name
    user_authorizer = self.class.authorization.user_authorizer
    service.authorization = user_authorizer.get_credentials(id.to_s)
    service
  end

  def email_address
    @email_address ||= reload_email_address
  end

  # TODO: Update method logic once we start automatically refreshing tokens.
  def reload_email_address
    raise 'invalid token status' unless safely_connected?
    @email_address = gmail.get_user_profile('me').email_address
  end
end
