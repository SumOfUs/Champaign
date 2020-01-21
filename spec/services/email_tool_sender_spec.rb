require 'rails_helper'

describe EmailToolSender do
  let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
  let(:registered_email) { create(:registered_email_address) }
  let(:targets) { build_list(:email_tool_target, 2) }

  let!(:plugin) do
    create(:email_tool,
           page: page,
           from_email_address: registered_email,
           targets: targets)
  end

  let(:params) do
    { from_email: 'john@email.com',
      from_name: 'John',
      body: 'Suspendisse vestibulum dolor et libero sollicitudin aliquam eu eu purus. Phasellus eget diam in felis
gravida mollis a vitae velit. Duis tempus dolor non finibus convallis. In in ipsum lacinia, pulvinar lectus nec,
condimentum sapien. Nunc non dui dolor. Ut ornare pretium nunc sed ornare. Praesent at risus a felis lacinia pretium
et a neque. Nam non mi in eros sollicitudin imperdiet.',
      subject: 'Some subject',
      country: 'US',
      akid: '1234.2342' }
  end

  before { allow(EmailSender).to receive(:run) }

  def expect_email_sender_to_be_called_with(params)
    expect(EmailSender).to receive(:run)
      .with(hash_including(params))
  end

  it 'calls EmailSender passing the page slug as id' do
    expect_email_sender_to_be_called_with(id: page.slug)
    EmailToolSender.run(page.id, params)
  end

  it 'calls EmailSender forwarding the body and subject params' do
    expect_email_sender_to_be_called_with(params.slice(:body, :subject))
    EmailToolSender.run(page.id, params)
  end

  context 'if use_member_email is true' do
    before { plugin.update! use_member_email: true }
    it 'sends the email from the members email address' do
      expect_email_sender_to_be_called_with(
        from_name: params[:from_name], from_email: params[:from_email]
      )
      EmailToolSender.run(page.id, params)
    end

    it 'sets the reply_to to both the member and the plugin from_email_address' do
      expect_email_sender_to_be_called_with(
        reply_to: a_collection_containing_exactly(
          { name: params[:from_name], email: params[:from_email] },
          { name: registered_email.name, email: registered_email.email }
        )
      )
      EmailToolSender.run(page.id, params)
    end
  end

  context 'if use_member_email is false' do
    it 'sends it from the plugin from_email_address' do
      expect_email_sender_to_be_called_with(
        from_name: params[:from_name], from_email: registered_email.email
      )
      EmailToolSender.run(page.id, params)
    end

    it 'sets the reply_to to the plugin from_email_address' do
      expect_email_sender_to_be_called_with(
        reply_to: [{ name: registered_email.name, email: registered_email.email }]
      )
      EmailToolSender.run(page.id, params)
    end
  end

  describe 'targeting' do
    it 'sends it to the test email if present' do
      plugin.update!(test_email_address: 'test@test.com')
      expect_email_sender_to_be_called_with(
        recipients: [{ name: 'Test Email', email: 'test@test.com' }]
      )
      EmailToolSender.run(page.id, params)
    end

    it 'sends it to the selected target if target_id is present' do
      target = targets.sample
      expect_email_sender_to_be_called_with(
        recipients: [{ name: target.name, email: target.email }]
      )
      EmailToolSender.run(page.id, params.merge(target_id: target.id))
    end

    it 'sends it to all targets if neither the test email nor the target_id are present' do
      expect_email_sender_to_be_called_with(
        recipients: a_collection_containing_exactly(
          *plugin.targets.map { |t| { name: t.name, email: t.email } }
        )
      )
      EmailToolSender.run(page.id, params)
    end
  end

  context 'creating an action' do
    it 'creates an action and member with the correct params (not-EEA country)' do
      service = EmailToolSender.new(page.id, params)
      expect {
        service.run
      }.to change(Action, :count).by(1)

      action = service.action
      expect(action.member&.email).to eq 'john@email.com'
      expect(action.member&.first_name).to eq 'John'
      expect(action.page).to eq page
    end

    it 'pushes the action to the queue with the mailing_id present' do
      allow(AkidParser).to receive(:parse).and_return(actionkit_user_id: 29_384, mailing_id: 12_309)
      payload = {
        type: 'action',
        meta: hash_including(
          title: 'Foo Bar'
        ),
        params: hash_including(
          page: "#{page.slug}-petition",
          email: 'john@email.com',
          page_id: page.id,
          user_en: 1,
          mailing_id: 12_309
        )
      }
      expect(ChampaignQueue).to receive(:push)
        .with(payload, group_id: /action:\d+/)
      EmailToolSender.new(page.id, params).run
    end
  end

  describe 'Validations' do
    it "fails if the plugin doesn't have a from_email_address configured" do
      plugin.update! from_email_address: nil
      service = EmailToolSender.new(page.id, params)

      expect(service.run).to be false
      expect(service.errors[:base]).to include('Please configure a From email address')
    end

    it "fails if the plugins doesn't have at least a target" do
      plugin.update! targets: []
      service = EmailToolSender.new(page.id, params)

      expect(service.run).to be false
      expect(service.errors[:base]).to include('Please configure at least one target')
    end

    it 'validates the presence of following fields: from_name, from_email, body and subject' do
      service = EmailToolSender.new(page.id, {})
      expect(service.run).to be false
      %i[from_name from_email body subject].each do |field|
        expect(service.errors[field]).to include("can't be blank")
      end
    end

    it 'validates the format of from_email' do
      service = EmailToolSender.new(page.id, from_email: 'wrongformat@')
      expect(service.run).to be false
      expect(service.errors[:from_email]).to include('is not an email')
    end

    it 'checks if the target_id is valid' do
      service = EmailToolSender.new(page.id, target_id: 'wrong')
      expect(service.run).to be false
      expect(service.errors[:base]).to include(/targets information has recently changed/)
    end

    it 'validates the presence of country' do
      service = EmailToolSender.new(page.id, {})
      expect(service.run).to be false
      expect(service.errors[:base]).to include('Please make sure a country is being sent')
    end
  end
end
