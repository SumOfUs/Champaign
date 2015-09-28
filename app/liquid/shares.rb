module Shares

  class << self

    # we're making the assumption that all that matters from the ShareProgress HTML
    # is the class, which is true in the JS file they're loading.
    # It makes it much easier to override the content and style
    # of the sharing buttons
    def get_all(page)
      all_buttons(page).inject({}) do |shares, button|
        css_class = class_from_html(button.sp_button_html)
        shares[button.sp_type] = css_class unless css_class.blank?
        shares
      end
    end

    def get_all_html(page)
      all_buttons(page).inject({}) do |shares, button|
        shares[button.sp_type] = button.sp_button_html.html_safe unless button.sp_button_html.blank?
        shares
      end
    end

    private

    def all_buttons(page)
      Share::Button.where(page_id: page.id)
    end

    def class_from_html(html)
      return nil if html.blank?
      class_finder = /class *= *['"](.*?)['"]/i
      html[class_finder, 1]
    end
  end

end
