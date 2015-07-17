describe Template do

  let(:widget_attributes) { attributes_for :widget }
  let(:template_attributes) { attributes_for :template, widgets_attributes: [widget_attributes] }

  let(:template) { create :template, widgets_attributes: [widget_attributes] }

  subject { template }

  it { should be_valid }
  it { should be_persisted }
  it { should respond_to :template_name }
  it { should respond_to :widgets }

  describe 'widgets' do

    before :each do
      template.save!
    end

    it "creates widgets" do
      expect { Template.create!(template_attributes) }.to change{ Widget.count }.by 1
    end

    it "can access the template from the widget as page" do
      expect(Widget.last.page).to eq template
    end

    it "can access the widget from the templates" do
      expect(template.widgets).to eq [Widget.last]
    end

    it "destroys the widget when the template is destroyed" do
      expect{ template.destroy }.to change{ Widget.count }.by -1
    end

    it "does not destroy the template when the widget is destroyed" do
      expect{ template.widgets.first.destroy }.to change{ Template.count }.by 0
    end

    it 'can destroy associated widgets with updates_attributes' do
      update_params = { widgets_attributes: [{id: template.widgets.first.id, _destroy: "true"}] }
      expect{ template.update_attributes update_params }.to change{ Widget.count }.by -1
    end

    it "won't destroy associated widgets updates_attributes with 'false'" do
      update_params = { widgets_attributes: [{id: template.widgets.first.id, _destroy: "false"}] }
      expect{ template.update_attributes update_params }.to change{ Widget.count }.by 0
    end
  end

end
