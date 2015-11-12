AssetSync.configure do |config|
  config.fog_provider = Settings.fog_provider
  config.aws_access_key_id = Settings.aws_access_key_id
  config.aws_secret_access_key = Settings.aws_secret_access_key
  config.fog_directory = Settings.fog_directory
  config.fog_region = Settings.fog_region
  config.run_on_precompile = Settings.asset_sync || false
  config.log_silently = false
  config.gzip_compression = Settings.asset_sync_gzip_compression || false
end
