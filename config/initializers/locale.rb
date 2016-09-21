# frozen_string_literal: true
# include the locale files from external asset directories, if relevant
if Settings.external_asset_paths.present? && Settings.external_translation_path.present?
  Settings.external_asset_paths.try(:split, ':').each do |directory|
    Rails.application.config.i18n.load_path += Dir[File.join(directory, Settings.external_translation_path, '*.{rb,yml}')]
  end
  # in the test environement, we want the translations from the Champaign repo to override those in
  # the asset repo because some of the integration specs involve VCR casettes including language
  # from the Champaign translations
  if Rails.env.test?
    champaign_locales = Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
    Rails.application.config.i18n.load_path += champaign_locales
  end
end
