# frozen_string_literal: true

namespace :assets do
  task :download_and_precompile, %i[url_template credentials branch source_assets_path] => :environment do |_t, args|
    if args[:url_template].blank?
      puts 'Not including any external assets'
      next
    end

    target_path = args[:source_assets_path] || './tmp/assets_source'
    FileUtils.mkdir_p target_path
    Rake::Task['assets:download_external_assets'].invoke(target_path, args[:url_template], args[:credentials], args[:branch])
    Rake::Task['assets:precompile_assets'].invoke(target_path)
  end

  # Downloads a tar from a URL, extracts its contents into <target_path>
  #
  # Params:
  # * target_path: the dir path where the contents of the downloaded and extracted files will be put
  # * url: any http[s] url. Optionally it can include a tag <branch> that will be replaced with
  #   the contents of the branch param.
  # * credentials: http basic auth credentials. The format should be user:password.
  # * branch: Mainly for Github URLs usage. The content of this param will replace the <branch> tag
  #   in the url param.
  #
  # Example:
  #  rake deploy:precompile_assets["https://api.github.com/repos/organisation/repo/tarball/<branch>","deploy-user:secret","master"]
  desc 'Download external assets'
  task :download_external_assets, %i[target_path url_template credentials branch] => :environment do |_t, args|
    target_path = args[:target_path]
    url_template = args[:url_template]
    credentials = args[:credentials]
    current_branch = args[:branch]
    tar_file_path = './tmp/assets.tar'

    if url_template.blank? || target_path.blank?
      raise 'usage: rake deploy:download_external_assets[target_path,url_template[,"user:password"][,branch]]'
    end

    FileUtils.remove_dir(target_path) if File.exist?(target_path)
    FileUtils.mkdir_p target_path

    urls = [current_branch, Settings.default_asset_branch, 'master'].map do |branch|
      branch.present? ? url_template.gsub('<branch>', branch) : nil
    end.compact

    # Set github credentials --------------------------
    http_options = {}
    if credentials.present?
      u, p = credentials.split(':')
      http_options[:basic_auth] = { username: u, password: p }
    end

    # Download tar file --------------------------
    errors = []
    response = nil
    urls.each do |url|
      puts "Downloading external assets from #{url}"
      response = HTTParty.get url, http_options
      break if response.success?
      errors << "HTTP error while trying to download assets from #{url}: #{response.inspect}"
    end
    unless response.success?
      errors[0...-1].each { |e| puts e }
      raise errors.last
    end

    # Extract tar file --------------------------
    `mkdir -p tmp`
    File.open(tar_file_path, 'w+b') do |file|
      file.write response.body
    end

    untar_cmd = "tar -xf #{tar_file_path} -C ./tmp"
    result = system(untar_cmd)
    raise "Error running `#{untar_cmd}`" unless result

    tmp_assets_dir = `tar -tf #{tar_file_path} | head -n 1`
    tmp_assets_dir.strip!

    # Move assets to to target_path

    files_to_mv = Dir.glob(Rails.root.join('tmp', tmp_assets_dir, '{.[^\.]*,*}'))
    FileUtils.mv files_to_mv, target_path
  end

  task :precompile_assets, [:external_asset_paths] => :environment do |_t, args|
    cmd = "RAILS_ENV=#{Rails.env} EXTERNAL_ASSETS_PATH=#{args[:external_asset_paths]} rake assets:precompile"
    puts "Running: #{cmd}"
    exec(cmd)
  end
end
