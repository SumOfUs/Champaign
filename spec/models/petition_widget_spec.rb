describe PetitionWidget do

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
    checkboxes: ['a', 'b', 'c'],
    select_box: { a: 'b', c: 'd' },
    comment_textarea: {},
    call_in_form: {},
    letter_sent_form: {},
    form_button_text: "Stop 'em!"
  } }
  let(:params) { { page_display_order: 1, content: content } }
  let(:widget) { PetitionWidget.create!(params) }

  subject { widget }
  it { should be_valid }

  describe 'inheritance' do

    it 'should be able to create a widget from the Widget class' do
      w2 = Widget.new(params.merge({type: "PetitionWidget"}))
      expect(w2).to be_valid
      expect(w2.form_button_text).to eq content[:form_button_text]
    end

  end

  describe 'content' do

    it "should have the initialized values" do
      expect(widget.form_button_text).to eq content[:form_button_text]
    end

    it "should be invalid without a required field" do
      widget.content.delete('petition_text')
      expect(widget.petition_text).to be_nil
      expect(widget).not_to be_valid
    end

    it "should be invalid with petition_text too short" do
      widget.petition_text = "meh"
      expect(widget).not_to be_valid
    end

    it "should be valid changin a non-required field" do
      widget.form_button_text = "Go!"
      expect(widget).to be_valid
    end

    it "should be valid without a non-required field" do
      widget.content.delete('form_button_text')
      expect(widget.form_button_text).to be_nil
      expect(widget).to be_valid
    end

    it "should enforce string types" do
      widget.petition_text = 123
      expect(widget).not_to be_valid
    end

    it "should be invalid with a non-spec'd key" do
      widget.content['not_a_real_field'] = "heyy"
      expect(widget).not_to be_valid
    end
  end

  describe 'actionkit_page' do

    let(:actionkit_page) { create :actionkit_page, widget: widget }

    it 'should find the widget from the actionkit_page' do
      expect(actionkit_page.widget).to eq widget
    end

    it 'should find the actionkit_page from the widget' do
      expect(actionkit_page).to be_persisted
      expect(widget.actionkit_page).to eq actionkit_page
    end

  end

end
