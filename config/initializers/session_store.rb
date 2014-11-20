# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: Rails.configuration.mihudie.session_cookie_name, :expire_after => 6.months
