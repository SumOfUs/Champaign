require 'rails_helper'

describe PensionEmailSender do
  let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
  let!(:plugin) {
    create(:email_pension, page: page, email_from: 'origin@example.com', name_from: 'ExampleOrg')
  }

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
      .with(hash_including(to_emails: { address: 'test@test.com', name: 'Test' }))
    PensionEmailSender.run(page.id, {})
  end

  it "sets the reply_to to the plugin#email_from and the member's email" do
    expect(EmailSender).to receive(:run)
      .with(
        hash_including(
          reply_to: [
            { address: 'origin@example.com', name: 'ExampleOrg' },
            { address: 'john@mail.com', name: 'John' }
          ]
        )
      )
    PensionEmailSender.run(page.id, from_name: 'John', from_email: 'john@mail.com')
  end

  it 'sets the page_slug' do
    expect(EmailSender).to receive(:run)
      .with(hash_including(page_slug: 'foo-bar'))
    PensionEmailSender.run(page.id, {})
  end
end
