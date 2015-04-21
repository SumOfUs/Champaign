# Be sure to restart your server when you modify this file.

Champaign::Application.config.session_store :redis_store, servers: 'redis://redis:6379/0/cache'
