require 'rails_helper'

describe PensionEmailSender do
  def expect_email_sender_to_be_called_with(params)
    expect(EmailSender).to receive(:run)
      .with(hash_including(params))
  end

  let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
  let(:registered_email) { create(:registered_email_address) }
  let!(:plugin) {
    create(:email_pension, page: page, from_email_address: registered_email)
  }

  it 'calls EmailSender forwarding valid params' do
    expect_email_sender_to_be_called_with(subject: 'subject', body: 'body')
    params = { subject: 'subject', body: 'body', wrong: 'wrong' }
    PensionEmailSender.run(page.id, params)
  end

  it "sets the 'to' field to the plugin test_email if present" do
    plugin.update(test_email_address: 'test@test.com')
    expect_email_sender_to_be_called_with(to: { address: 'test@test.com', name: 'Test' })
    PensionEmailSender.run(page.id, {})
  end

  context 'given use_member_email is true' do
    before { plugin.update! use_member_email: true }
    it 'sends the email from the members email address' do
      expect_email_sender_to_be_called_with(
        from_name: 'John', from_email: 'john@mail.com'
      )
      PensionEmailSender.run(page.id, from_name: 'John', from_email: 'john@mail.com')
    end

    it 'sets the reply_to to both the member and the plugin from_email_address' do
      expect_email_sender_to_be_called_with(
        reply_to: a_collection_containing_exactly(
          { name: 'John', address: 'john@mail.com' },
          { name: registered_email.name, address: registered_email.email }
        )
      )
      PensionEmailSender.run(page.id, from_name: 'John', from_email: 'john@mail.com')
    end
  end

  context 'given use_member_email is false' do
    it 'sends it from the plugin from_email_address' do
      expect_email_sender_to_be_called_with(
        from_name: registered_email.name, from_email: registered_email.email
      )
      PensionEmailSender.run(page.id, {})
    end

    it 'sets the reply_to to the plugin from_email_address' do
      expect_email_sender_to_be_called_with(
        reply_to: [{ name: registered_email.name, address: registered_email.email }]
      )
      PensionEmailSender.run(page.id, {})
    end
  end

  it 'sets the id to the page_slug' do
    expect_email_sender_to_be_called_with(id: 'foo-bar')
    PensionEmailSender.run(page.id, {})
  end
end
