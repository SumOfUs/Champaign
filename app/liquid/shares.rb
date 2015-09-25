module Shares
  def self.get_all(page)
    Share::Button.where(page_id: page.id).inject({}) do |shares, button|
      shares[button.sp_type] = button.sp_button_html.html_safe unless button.sp_button_html.blank?
      shares
    end
  end
end
