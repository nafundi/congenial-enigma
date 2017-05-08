require 'googleauth/token_store'

# TODO: Automatically refresh expired tokens.
class OauthToken < ApplicationRecord
  belongs_to :configured_service
  validates :configured_service, presence: true
  validates :configured_service_id, uniqueness: true

  validates :access_token, :expires_at, presence: true

  def self.google_token_store
    Store
  end

  def seconds_to_expiration
    seconds = expires_at - Time.now
    seconds > 0 ? seconds.floor : 0
  end

  def expired?
    expires_at < Time.now
  end

  protected

  # TODO: The methods below may raise errors. Should
  # ConfiguredServices::Gmail.user_authorizer rescue them?
  class Store < Google::Auth::TokenStore
    class << self
      def load(configured_service_id_string)
        token = find_token(configured_service_id_string)
        ActiveSupport::JSON.encode(
          access_token: token.access_token,
          expiration_time_millis: token.expires_at.to_i * 1000
        )
      end

      def store(configured_service_id, token_json)
        token = find_token(configured_service_id_string)
        token_hash = ActiveSupport::JSON.decode(token_json)
        expires_at = Time.at(token_hash['expiration_time_millis'] / 1000)
        token.update! access_token: token_hash['access_token'],
                      expires_at: expires_at
      end

      def delete(configured_service_id_string)
        find_token(configured_service_id_string).destroy!
      end

      private

      def find_token(configured_service_id_string)
        id = Integer(configured_service_id_string, 10)
        OauthToken.find_by!(configured_service_id: id)
      end
    end
  end
end
