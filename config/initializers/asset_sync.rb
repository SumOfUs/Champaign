AssetSync.configure do |config|
  config.fog_provider = ENV['FOG_PROVIDER']
  config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.fog_directory = ENV['FOG_DIRECTORY']
  config.fog_region = ENV['FOG_REGION']
  config.run_on_precompile = false
end