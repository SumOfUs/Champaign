require 'rails_helper'

RSpec.describe PetitionWidget, type: :model do

  let(:content) { {
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
  let(:widget) { PetitionWidget.new(params) }

  subject { widget }
  it { should be_valid }

  describe 'inheritance' do

    it 'should be able to create a widget from the Widget class' do
      w2 = Widget.new(params.merge({type: "PetitionWidget"}))
      expect(w2).to be_valid
      expect(w2.content['form_button_text']).to eq content[:form_button_text]
    end

  end

  describe 'content' do

    it "should have the initialized values" do
      expect(widget.content['form_button_text']).to eq content[:form_button_text]
    end

    it "should be invalid without a required field" do
      widget.content.delete('petition_text')
      expect(widget.content['petition_text']).to be_nil
      expect(widget).not_to be_valid
    end

    it "should be invalid with petition_text too short" do
      widget.content['petition_text'] = "meh"
      expect(widget).not_to be_valid
    end

    it "should be valid changin a non-required field" do
      widget.content['form_button_text'] = "Go!"
      expect(widget).to be_valid
    end

    it "should be valid without a non-required field" do
      widget.content.delete('form_button_text')
      expect(widget.content['form_button_text']).to be_nil
      expect(widget).to be_valid
    end

    it "should enforce string types" do
      widget.content['petition_text'] = 123
      expect(widget).not_to be_valid
    end

    it "should be invalid with a non-spec'd key" do
      widget.content['not_a_real_field'] = "heyy"
      expect(widget).not_to be_valid
    end
  end
end
