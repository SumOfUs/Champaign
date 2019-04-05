# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id                   :integer          not null, primary key
#  content_content_type :string
#  content_file_name    :string
#  content_file_size    :bigint(8)
#  content_updated_at   :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  page_id              :integer
#
# Indexes
#
#  index_images_on_page_id  (page_id)
#

describe Image do
  it { should have_attached_file(:content) }
  it { should validate_attachment_presence(:content) }
  it do
    should validate_attachment_content_type(:content)
      .allowing('image/tiff', 'image/jpeg', 'image/jpg', 'image/png', 'image/x-png', 'image/gif')
      .rejecting('text/plain', 'text/xml', 'text/javascript')
  end
  it { should validate_attachment_size(:content).less_than(20.megabytes) }

  let(:image_file) { File.new(Rails.root.join('spec', 'fixtures', 'test-image.gif')) }
  let(:image) { Image.create!(content: image_file) }

  after :each do
    # when rspec cleans up, it doesn't actually commit like normal,
    # so paperclip's file delete callback isn't called.
    Image.all.map do |i|
      i.destroy
      i.run_callbacks(:commit)
    end
  end

  it 'should create the image file' do
    path = image.content.path
    expect(File).to exist Rails.root.join(path)
  end

  it 'should destroy the image file on delete' do
    path = image.content.path
    expect(image.destroy).to be_truthy
    image.run_callbacks(:commit)
    expect(Image.count).to eq 0
    expect(File).not_to exist Rails.root.join(path)
  end
end
