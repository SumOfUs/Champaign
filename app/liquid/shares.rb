# frozen_string_literal: true

module Shares
  class << self
    # we're making the assumption that all that matters from the ShareProgress HTML
    # is the class, which is true in the JS file they're loading.
    # It makes it much easier to override the content and style
    # of the sharing buttons
    def get_all(page)
      buttons_with_variants(page).inject({}) do |shares, button|
        view_params = {
          css_class: class_from_html(button.share_button_html)
        }
        unless button.share_progress?
          variant = select_share_variant(button.share_type, page)
          view_params[:variant_id] = variant.id
          # Prepend the desired query parameters (uri encoded) into the url we want to share
          url = button.url << ERB::Util.url_encode("?src=whatsapp&variant_id=#{variant.id}")
          view_params[:link_html] = button.share_button_html.gsub('%7BLINK%7D', url)
        end
        shares[button.share_type] = view_params
        shares
      end
    end

    def get_all_html(page)
      buttons_with_variants(page).inject({}) do |shares, button|
        shares[button.share_type] = button.share_button_html.html_safe unless button.share_button_html.blank?
        shares
      end
    end

    private

    def select_share_variant(share_type, page)
      # Whatsapp variants are served locally rather than from ShareProgress, so we need to find a way to decide
      # which whatsapp share to show. The easiest way is to choose by random.
      variant_class(share_type).where(page_id: page.id).order('RANDOM()').first
    end

    def variant_class(share_type)
      "Share::#{share_type.classify}".constantize
    end

    def buttons_with_variants(page)
      # Find all buttons that have share variants and that have a corresponding page_id
      Share::Button.find(Share::Variant.all.map(&:button_id)).select { |button| button.page_id == page.id }
    end

    def class_from_html(html)
      return nil if html.blank?
      class_finder = /class *= *['"](.*?)['"]/i
      html[class_finder, 1]
    end
  end
end
