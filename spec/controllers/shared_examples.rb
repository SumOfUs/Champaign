# frozen_string_literal: true

shared_examples 'session authentication' do |actions = []|
  let(:session_user) { double }

  before do
    allow(request.env['warden']).to receive(:authenticate!) { session_user }
  end

  actions.each do |action|
    action.each do |verb, arguments|
      it "authenticates session for #{arguments.first}" do
        expect(request.env['warden']).to receive(:authenticate!)
        send(verb, *arguments)
      end
    end
  end
end
