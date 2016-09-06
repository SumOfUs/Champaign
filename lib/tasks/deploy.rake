namespace :deploy do
  # Downloads a tar from a URL, extracts its contents into ./tmp,
  # and returns a colon separated list of paths belonging to the first level directories
  # inside the original tar file.
  #
  # Params:
  # * url: any http[s] url. Optionally it can include a tag <branch> that will be replaced with
  #    the contents of the branch param.
  # * credentials: http basic auth credentials. The format should be user:password.
  # * branch: Mainly for Github URLs usage. The content of this param will replace the <branch> tag
  #     in the url param.
  #
  # Example:
  #  rake deploy:precompile_assets["https://api.github.com/repos/organisation/repo/tarball/<branch>","deploy-user:secret","master"]
  desc "Download external assets"
  task :precompile_assets, [:url, :credentials, :branch] => :environment do |t, args|
    url_template = args[:url]
    credentials = args[:credentials]
    current_branch = args[:branch]
    tar_file_path = "./tmp/assets.tar"


    if url_template.blank?
      puts "Not including any external assets"
      next
    end

    urls = [current_branch, Settings.default_asset_branch, 'master'].map do |branch|
      branch.present? ? url_template.gsub("<branch>", branch) : nil
    end.compact

    # Set github credentials --------------------------
    http_options = {}
    if credentials.present?
      u, p = credentials.split(":")
      http_options[:basic_auth] = { username: u, password: p }
    end

    # Download tar file --------------------------
    errors, response = [], nil
    urls.each do |url|
      puts "Including external assets from #{url}"
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
    File.open(tar_file_path, "w+b") do |file|
      file.write response.body
    end

    untar_cmd = "tar -xf #{tar_file_path} -C ./tmp"
    result = system(untar_cmd)
    raise "Error running `#{untar_cmd}`" unless result

    assets_dir = `tar -tf #{tar_file_path} | head -n 1`
    assets_dir.strip!
    assets_dir_full_path = Rails.root.join("tmp", assets_dir)

    cmd = "RAILS_ENV=#{Rails.env} EXTERNAL_ASSETS_PATHS=#{assets_dir_full_path} rake assets:precompile"
    puts "Running: #{cmd}"
    exec(cmd)
  end
end
