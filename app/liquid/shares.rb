# frozen_string_literal: true

module Shares
  class << self
    # we're making the assumption that all that matters from the ShareProgress HTML
    # is the class, which is true in the JS file they're loading.
    # It makes it much easier to override the content and style
    # of the sharing buttons
    def get_all(page)
      buttons_with_variants(page).inject({}) do |shares, button|
        css_class = class_from_html(button.sp_button_html)
        shares[button.sp_type] = {
          css_class: css_class,
          sp_button_html: button.sp_button_html
        }
        shares
      end
    end

    def get_all_html(page)
      buttons_with_variants(page).inject({}) do |shares, button|
        shares[button.sp_type] = button.sp_button_html.html_safe unless button.sp_button_html.blank?
        shares
      end
    end

    private

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
