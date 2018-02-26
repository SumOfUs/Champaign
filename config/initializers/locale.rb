# frozen_string_literal: true

# include the locale files from external asset directories, if relevant
Rails.application.config.after_initialize do
  if Settings.external_assets_path.present? && Settings.external_translation_path.present?
    Settings.external_assets_path.try(:split, ':').each do |directory|
      files = Dir[File.join(directory, Settings.external_translation_path, '*.{rb,yml}')]
      I18n.load_path += files
    end
    # in the test environement, we want the translations from the Champaign repo to override those in
    # the asset repo because some of the integration specs involve VCR casettes including language
    # from the Champaign translations
    if Rails.env.test?
      champaign_locales = Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
      I18n.load_path += champaign_locales
    end
  end
end
