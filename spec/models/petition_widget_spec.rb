require 'rails_helper'

RSpec.describe PetitionWidget, type: :model do

  let(:content) { {
    city: "London",
    country: "England",
    petition_text: "Stop rails developers writing tests!",
    require_full_name: true,
    require_email_address: true,
    require_state: false,
    require_country: false,
    require_postal_code: false,
    require_address: false,
    require_city: false,
    require_phone: false,
    checkboxes: [],
    select_box: {},
    comment_textarea: {},
    call_in_form: {},
    letter_sent_form: {},
    form_button_text: "Stop 'em!"
  } }
  let(:params) { { page_display_order: 1, content: content } }
  let(:petition_widget) { PetitionWidget.new(params) }

  subject { widget }
  it { should be_valid }

  describe :content do

    it "should be invalid without a city" do
      widget.content[:city] = nil
      expect(widget).not_to be_valid
    end
  end
end
