# frozen_string_literal: true

require "omniauth/strategies/france_connect_uid"
require "omniauth/strategies/france_connect_profile"

if Rails.application.secrets.dig(:omniauth_enable_multi_tenant) == 1
  Rails.application.config.middleware.use OmniAuth::Builder do
    OmniAuth.config.logger = Rails.logger

    omniauth_config = Rails.application.secrets.dig(:omniauth)

    if omniauth_config[:france_connect_uid].present?
      provider(
        :france_connect_uid,
        setup: setup_provider_proc(:france_connect_uid,
                                   site: :site,
                                   client_id: :client_id,
                                   client_secret: :client_secret,
                                   end_session_endpoint: :end_session_endpoint,
                                   icon_path: :icon_path,
                                   button_path: :button_path,
                                   provider_name: :provider_name,
                                   minimum_age: :minimum_age)
      )
    end

    if omniauth_config[:france_connect_profile].present?
      provider(
        :france_connect_profile,
        setup: setup_provider_proc(:france_connect_profile,
                                   site: :site,
                                   client_id: :client_id,
                                   client_secret: :client_secret,
                                   end_session_endpoint: :end_session_endpoint,
                                   icon_path: :icon_path,
                                   button_path: :button_path,
                                   provider_name: :provider_name,
                                   minimum_age: :minimum_age)
      )
    end
  end
else
  ::Devise.setup do |config|
    omniauth_config = Rails.application.secrets.dig(:omniauth)

    if omniauth_config.dig(:france_connect_uid, :enabled) == 1
      config.omniauth :france_connect_uid,
                      name: "france_connect_uid",
                      site: omniauth_config.dig(:france_connect_uid, :site),
                      client_id: omniauth_config.dig(:france_connect_uid, :client_id),
                      client_secret: omniauth_config.dig(:france_connect_uid, :client_secret),
                      end_session_endpoint: omniauth_config.dig(:france_connect_uid, :end_session_endpoint),
                      icon_path: omniauth_config.dig(:france_connect_uid, :icon_path),
                      button_path: omniauth_config.dig(:france_connect_uid, :button_path),
                      provider_name: omniauth_config.dig(:france_connect_uid, :provider_name),
                      minimum_age: omniauth_config.dig(:france_connect_uid, :minimum_age)&.to_i
    end

    if omniauth_config.dig(:france_connect_profile, :enabled) == 1
      config.omniauth :france_connect_profile,
                      name: "france_connect_profile",
                      site: omniauth_config.dig(:france_connect_profile, :site),
                      client_id: omniauth_config.dig(:france_connect_profile, :client_id),
                      client_secret: omniauth_config.dig(:france_connect_profile, :client_secret),
                      end_session_endpoint: omniauth_config.dig(:france_connect_profile, :end_session_endpoint),
                      icon_path: omniauth_config.dig(:france_connect_profile, :icon_path),
                      button_path: omniauth_config.dig(:france_connect_profile, :button_path),
                      provider_name: omniauth_config.dig(:france_connect_profile, :provider_name),
                      minimum_age: omniauth_config.dig(:france_connect_profile, :minimum_age)&.to_i
    end
  end
end
