require 'rails_helper'

describe EmailToolSender do
  let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
  let(:registered_email) { create(:registered_email_address) }
  target_data = [{ email: 'rando1@example.org', name: 'Random One' },
                 { email: 'rando2@example.org', name: 'Random Two' }]
  targets = target_data.map { |t| FactoryBot.create(:email_tool_target, t) }
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
      akid: '1234.2342',
      target_id: targets.first.id }
  end

  before { allow(EmailSender).to receive(:run) }

  def expect_email_sender_to_be_called_with(params)
    expect(EmailSender).to receive(:run)
      .with(hash_including(params))
  end

  context 'creating an action' do
    it 'assigns default value for country if the value is nil' do
      service = EmailToolSender.new(page.id, params.merge(country: nil))
      expect {
        service.run
      }.to change(Action, :count).by(1)
      expect(service.action.form_data['country']).to eq 'US'
    end

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

    context 'single target' do
      it 'pushes the action to the queue with the mailing_id and custom fields present' do
        allow(AkidParser).to receive(:parse).and_return(actionkit_user_id: 29_384, mailing_id: 12_309)
        payload = {
          type: 'action',
          meta: hash_including(
            title: 'Foo Bar'
          ),
          params: hash_including(
            page: "#{page.ak_slug}-petition",
            email: 'john@email.com',
            page_id: page.id,
            user_en: 1,
            mailing_id: 12_309,
            action_target: 'Random One',
            action_target_email: 'rando1@example.org'
          )
        }
        expect(ChampaignQueue).to receive(:push)
          .with(payload, group_id: /action:\d+/)
        EmailToolSender.new(page.id, params).run
      end
    end

    context 'multiple targets' do
      let(:params) do
        { from_email: 'john@email.com',
          from_name: 'John',
          body: 'Suspendisse vestibulum dolor et libero sollicitudin aliquam eu eu purus. Phasellus eget diam in felis
gravida mollis a vitae velit. Duis tempus dolor non finibus convallis. In in ipsum lacinia, pulvinar lectus nec,
condimentum sapien. Nunc non dui dolor. Ut ornare pretium nunc sed ornare. Praesent at risus a felis lacinia pretium
et a neque. Nam non mi in eros sollicitudin imperdiet.',
          subject: 'Some subject',
          country: 'US',
          akid: '1234.2342',
          target_id: 'all' }
      end
      it 'passes "multiple" as target data into the custom fields' do
        allow(AkidParser).to receive(:parse).and_return(actionkit_user_id: 29_384, mailing_id: 12_309)
        payload = hash_including(
          params: hash_including(
            action_target: 'multiple',
            action_target_email: [
              { email: 'rando1@example.org', name: 'Random One' },
              { email: 'rando2@example.org', name: 'Random Two' }
            ]
          )
        )
        expect(ChampaignQueue).to receive(:push)
          .with(payload, group_id: /action:\d+/)
        EmailToolSender.new(page.id, params).run
      end
    end
  end

  describe 'Validations' do
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
  end
end
