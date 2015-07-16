class PetitionWidget < Widget
  extend StoreWith.model
  has_one :actionkit_page, foreign_key: :widget_id

  validates :petition_text, length: { minimum: 5 }

  store_with :content do
    petition_text         :string
    form_button_text      :string
    require_full_name     :boolean
    require_email_address :boolean
    require_country       :boolean
    require_state         :boolean
    require_postal_code   :boolean
    require_address       :boolean
    require_city          :boolean
    require_phone         :boolean
    checkboxes            :array
    select_box            :dictionary
    comment_textarea      :dictionary
    letter_sent_form      :dictionary
  end
end

