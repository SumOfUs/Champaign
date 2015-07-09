describe Image do

  it { should have_attached_file(:content) }
  it { should validate_attachment_presence(:content) }
  it { should validate_attachment_content_type(:content).
                allowing("image/tiff", "image/jpeg", "image/jpg", "image/png", "image/x-png", "image/gif").
                rejecting('text/plain', 'text/xml', "text/javascript") }
  it { should validate_attachment_size(:content).less_than(20.megabytes) }

end
