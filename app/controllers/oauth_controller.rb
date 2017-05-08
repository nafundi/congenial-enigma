class OauthController < ApplicationController
  # TODO: Account for errors and database failures.
  def google
    service = ConfiguredServices::Gmail.find(params[:state])
    client = service.class.authorization.client
    client.code = params[:code]
    client.fetch_access_token!
    attributes = {
      access_token: client.access_token,
      expires_at: client.expires_at
    }
    # TODO: Update this logic once we start automatically refreshing tokens.
    if service.oauth_token.present?
      service.oauth_token.update attributes
    else
      service.create_oauth_token attributes
    end
    redirect_to new_integration_path
  end
end
