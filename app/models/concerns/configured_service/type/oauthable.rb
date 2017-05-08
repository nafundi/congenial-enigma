module ConfiguredService::Type::Oauthable
  extend ActiveSupport::Concern

  included do
    has_one :oauth_token, dependent: :destroy

    class_attribute :_oauthable
    self._oauthable = false
  end

  class_methods do
    def oauthable
      self._oauthable = true
    end

    def oauthable?
      _oauthable
    end

    def oauthable!
      raise 'not oauthable' unless oauthable?
    end
  end

  def oauth_token
    self.class.oauthable!
    super
  end
end
