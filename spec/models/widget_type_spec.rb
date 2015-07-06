require 'rails_helper'

describe WidgetType do
  widget = WidgetType.new widget_name: 'Test Widget'

  it 'should generate its own form partial location' do
    expect(widget.form_partial_path).to eq 'widgets/test_widget/form.slim'
  end

  it 'should generate its own display partial location' do
    expect(widget.display_partial_path).to eq 'widgets/test_widget/display.slim'
  end
end
