require 'rails_helper'

describe PensionEmailSender do
  let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
  let!(:plugin) { create(:email_pension, page: page, email_from: 'origin@example.com') }

  it 'calls EmailSender forwarding valid params' do
    expect(EmailSender).to receive(:run).with(
      hash_including(subject: 'subject', body: 'body')
    )
    params = { subject: 'subject', body: 'body', wrong: 'wrong' }
    PensionEmailSender.run(page.id, params)
  end

  it 'sets the to_email to the plugin test_email if present' do
    plugin.update(test_email_address: 'test@test.com')
    expect(EmailSender).to receive(:run)
      .with(hash_including(to_email: 'test@test.com'))
    PensionEmailSender.run(page.id, {})
  end

  it 'sets the source_email to according to the plugin config' do
    expect(EmailSender).to receive(:run)
      .with(hash_including(source_email: 'origin@example.com'))
    PensionEmailSender.run(page.id, {})
  end

  it 'sets the page_slug' do
    expect(EmailSender).to receive(:run)
      .with(hash_including(page_slug: 'foo-bar'))
    PensionEmailSender.run(page.id, {})
  end
end
