# frozen_string_literal: true
##
# The <tt>PageUpdater</tt> class serves to update a Page model along with
# its associate Plugins and Share Variants. It allows for comprehensive saving
# and updating with one form from the user perspective.
#
# The +update+ method updates pages, plugins, and share variants that are passed
# to it. It returns true if all saves passed without errors and false if any of
# the saves returned errors. It will not rollback save on one entity if save
# failed on another. It expects params of the following format. Any of the hashes
# can be left out, only those present will be updated.
#   {
#     page: {
#       content: "my content",
#       id: "608"
#     },
#     plugins_petition_150: {
#       cta: "Sign the Petition",
#       description: "Tell those meanieheads to do something!",
#       id: "150",
#       name: "Petition",
#       ref: "",
#       target: ""
#     },
#     plugins_thermometer_81: {
#       id: "81",
#       name: "Thermometer",
#       offset: "0",
#       ref: ""
#     },
#     share_facebook_12: {
#       description: "and this is the message",
#       id: "12",
#       image_id: "16",
#       name: "facebook",
#       title: "This is the title"
#     },
#     share_twitter_1: {
#       description: "I want you to {LINK} for me",
#       id: "1",
#       name: "twitter"
#     },
#     share_twitter_2: {
#       description: "I want you to {LINK} for me",
#       id: "2",
#       name: "twitter"
#     }
#   }
#
# Some fields change the plugins available to the page, so these are listed
# as REFRESH_TRIGGERS. If one of these fields is updated, the +refresh?+ method
# will return true, otherwise it will return false.
#
# Finally, the +errors+ method will return a hash where each key is the name of the
# updated entity (eg :share_twitter_2 or :page) and the value is the AR errors hash
# for that object. The key will only be present if there are errors for that entity.
#

class PageUpdater
  attr_reader :errors

  def initialize(page, page_url = nil)
    @page = page
    @page_url = page_url
  end

  def update(params)
    @params = params
    @errors = {}
    @refresh = false
    update_plugins
    update_shares
    update_page
    @errors.empty?
  end

  def refresh?
    @refresh || false
  end

  private

  def important_changes_made
    page_tags_before = @page.pages_tags.map(&:tag_id)

    yield if block_given?

    page_tags_after = @page.pages_tags.map(&:tag_id)

    @page.changed_attributes.keys.any? do |attr|
      %w(language_id title campaign_id).include?(attr)
    end || page_tags_before != page_tags_after
  end

  def update_page
    return unless @params[:page]
    plugins_before = @page.plugins

    ak_sensitive_changes = important_changes_made do
      @page.assign_attributes(@params[:page])
    end

    if @page.save && ak_sensitive_changes
      QueueManager.push(@page, job_type: :update_pages)
    end

    @refresh = (@page.plugins != plugins_before)
    @errors[:page] = @page.errors.to_h unless @page.errors.empty?
  end

  def update_plugin(plugin_params)
    plugin = plugins.select { |p| p.id == plugin_params[:id].to_i && p.name == plugin_params[:name] }.first
    raise ActiveRecord::RecordNotFound if plugin.blank?
    plugin.update_attributes(without_name(plugin_params))
    plugin.errors
  end

  def update_share(share_params, _name)
    variant = if share_params[:id].present?
                ShareProgressVariantBuilder.update(
                  params: without_name(share_params),
                  variant_type: share_params[:name],
                  page: @page,
                  id: share_params[:id]
                )
              else
                ShareProgressVariantBuilder.create(
                  params: without_name(share_params),
                  variant_type: share_params[:name],
                  page: @page,
                  url: @page_url
                )
              end
    variant.errors
  end

  def update_plugins
    params_for('plugins').each_pair do |name, plugin_params|
      errors = update_plugin(plugin_params)
      @errors[name] = errors.to_h unless errors.blank?
    end
  end

  def update_shares
    params_for('share').each_pair do |name, share_params|
      errors = update_share(share_params, name)
      @errors[name] = errors.to_h unless errors.blank?
    end
  end

  def params_for(query)
    @params.select do |key, _value|
      key.to_s =~ /.*#{query}.*/i
    end
  end

  def plugins
    @page.plugins
  end

  def without_name(params)
    params.select { |k| k.to_sym != :name }
  end
end
