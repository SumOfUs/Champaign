consent_ # frozen_string_literal: true

require 'rails_helper'

describe 'Api Actions' do
  let(:sqs_client) { double }

  before do
    allow(ChampaignQueue).to receive(:push)
  end

  let(:page) { create(:page,  title: 'Foo Bar') }
  let(:form) { create(:form_with_email) }

  let(:headers) do
    {
      'HTTP_ACCEPT'           => '*/*',
      'HTTP_ACCEPT_LANGUAGE'  => 'en',
      'HTTP_ACCEPT_ENCODING'  => '*',
      'HTTP_USER_AGENT'       => 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D257',
      'referer'               => 'www.google.com'
    }
  end

  describe 'POST#create' do
    let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
    let(:form) { create(:form_with_email_and_optional_country) }

    let(:params) do
      {
        email:    'hello@example.com',
        form_id:  form.id,
        source:   'fb',
        country:  'FR',
        consented: 'true',
        akid:     '1234.5678.tKK7gX',
        referring_akid: '1234.5678.tKK7gX',
        name: 'Bob Mash'
      }
    end

    let(:message_body) do
      {
        type: 'action',
        meta: hash_including(title:      'Foo Bar',
                             uri:        '/a/foo-bar',
                             slug:       'foo-bar',
                             first_name: 'Bob',
                             last_name:  'Mash',
                             created_at: be_within(1.second).of(Time.zone.now),
                             country: 'France',
                             subscribed_member: true,
                             action_id: instance_of(Integer)),

        params: hash_including(page:    'foo-bar-petition',
                               email:  'hello@example.com',
                               name:   'Bob Mash',
                               page_id: page.id.to_s,
                               form_id: form.id.to_s,
                               source: 'fb',
                               akid:   '1234.5678.tKK7gX',
                               referring_akid: '1234.5678.tKK7gX',
                               action_mobile: 'mobile',
                               action_referer: 'www.google.com',
                               user_en: 1)
      }
    end

    describe 'Consent support' do
      let(:base_params) do
        {
          email:    'hello@example.com',
          form_id:  form.id,
          source:   'fb',
          country:  'DE',
          name: 'Bob Mash'
        }
      end

      it 'skips consent checks when no consent params are present' do
        expect {
          post "/api/pages/#{page.id}/actions",
               params: base_params,
               headers: headers
        }.to change { Action.count }.by 1
      end

      context 'when `consent_enabled=false` or not present' do
        context 'and country is in the EEA' do
          it 'ignores `consented=true` param' do
            expect {
              post "/api/pages/#{page.id}/actions",
                   params: base_params.merge(country: 'LI', consented: '1'),
                   headers: headers
            }.to change { Action.count }.by 1
          end

          it 'ignores `consented=false` param' do
            expect {
              post "/api/pages/#{page.id}/actions",
                   params: base_params.merge(country: 'LI', consented: '0'),
                   headers: headers
            }.to change { Action.count }.by 1
          end
        end
      end

      context 'when `consent_enabled=true`' do
        context 'and country is in the EEA' do
          it 'creates action if `consented=true`' do
            expect {
              post "/api/pages/#{page.id}/actions",
                   params: base_params.merge(country: 'LI', consent_enabled: '1', consented: '1'),
                   headers: headers
            }.to change { Action.count }.by 1
          end

          it 'sets `consented_at` if `consented=true`' do
            Timecop.freeze do
              post "/api/pages/#{page.id}/actions",
                   params: base_params.merge(country: 'LI', consent_enabled: '1', consented: '1'),
                   headers: headers
              last_member = Member.last
              expect(last_member.consented_at.utc).to be_within(1.second).of(Time.now.utc)
            end
          end

          it 'responds with success and a follow_up_url when `consented=true`' do
            post "/api/pages/#{page.id}/actions",
                 params: base_params.merge(country: 'LI', consent_enabled: '1', consented: '1'),
                 headers: headers
            expect(response).to be_success
            expect(response.body).to match('follow_up_url')
          end

          it 'does not create an action when `consented=false`' do
            expect {
              post "/api/pages/#{page.id}/actions",
                   params: base_params.merge(country: 'LI', consent_enabled: '1', consented: '0'),
                   headers: headers
            }.to change { Action.count }.by 0
          end

          it 'responds with success and a follow_up_url when `consented=false`' do
            post "/api/pages/#{page.id}/actions",
                 params: base_params.merge(country: 'LI', consent_enabled: '1', consented: '0'),
                 headers: headers
            expect(response).to be_success
            expect(response.body).to match('follow_up_url')
          end
        end

        context 'and country is not in the EEA' do
          it 'skips consent checks when `consented=false`' do
            expect {
              post "/api/pages/#{page.id}/actions",
                   params: base_params.merge(
                     country: 'CA',
                     consent_enabled: '1',
                     consented: '0'
                   ),
                   headers: headers
            }.to change { Action.count }.by 1
          end
        end
      end
    end

    describe 'queue' do
      before do
        post "/api/pages/#{page.id}/actions", params: params, headers: headers
      end

      it 'pushes action to queue' do
        expect(ChampaignQueue).to have_received(:push).with(message_body, group_id: /action:\d+/)
      end
    end

    ## TODO: Over testing... Should be a unit test
    #
    describe 'edge case country names' do
      CountriesExtension::COUNTRIES.each do |code, name|
        it "successfully posts #{name}" do
          params[:country] = code.upcase
          post "/api/pages/#{page.id}/actions", params: params

          expect(ChampaignQueue).to have_received(:push).with(
            hash_including(
              params: hash_including(
                country: name
              )
            ),
            group_id: /action:\d+/
          )
        end
      end
    end

    describe 'existing action' do
      let!(:member) { create :member, actionkit_user_id: '7777', email: params[:email] }
      let(:page2) { create :page }

      subject { post "/api/pages/#{page.id}/actions", params: params }

      it 'creates a new action if existing action on a different page' do
        create :action, member: member, page: page2
        expect { subject }.to change { Action.count }.by 1
      end

      it 'does not create an action if existing action on this page' do
        create :action, member: member, page: page
        expect { subject }.not_to change { Action.count }
      end

      it 'does not create an action if existing action of different page in same campaign' do
        create :action, member: member, page: page2
        create :campaign, pages: [page, page2]
        expect { subject }.not_to change { Action.count }
      end
    end

    describe 'page allows duplicate actions' do
      let!(:member) { create :member, actionkit_user_id: '7777', email: params[:email] }

      before do
        page.update(allow_duplicate_actions: true)
      end

      subject { post "/api/pages/#{page.id}/actions", params: params }

      it 'creats an action if existing action on this page' do
        create :action, member: member, page: page
        expect { subject }.to change { Action.count }
      end
    end

    describe 'akid manipulation' do
      context 'new member' do
        before do
          post "/api/pages/#{page.id}/actions", params: params
        end

        it 'persists action' do
          expect(page.actions.count).to eq(1)
        end

        it 'saves akid on action' do
          expect(
            Action.where('form_data @> ?', { akid: '1234.5678.tKK7gX' }.to_json).first
          ).to eq(page.actions.first)
        end

        it 'saves actionkit_user_id on member' do
          expect(Member.last.actionkit_user_id).to eq('5678')
        end
      end

      context 'existing member' do
        let!(:member) { create :member, actionkit_user_id: '7777', email: params[:email] }

        it 'overwrites existing actionkit_user_id' do
          post "/api/pages/#{page.id}/actions", params: params
          expect(member.reload.actionkit_user_id).to eq '5678'
        end
      end
    end
  end

  # TODO: Over testing. This should be a unit test.
  #
  ['long_string_with_underscore', '1234.5678', '2', '?&=', '2..2', '..2'].each do |invalid_akid|
    describe "invalid akid '#{invalid_akid}'" do
      let(:params) do
        {
          email: 'hello@example.com',
          form_id: form.id,
          akid: invalid_akid
        }
      end

      context 'existing member' do
        let!(:member) { create :member, actionkit_user_id: '1234', email: params[:email] }

        it 'does not overwrite existing actionkit_user_id' do
          post "/api/pages/#{page.id}/actions", params: params
          expect(member.reload.actionkit_user_id).to eq '1234'
        end
      end

      context 'new member' do
        before do
          post "/api/pages/#{page.id}/actions", params: params
        end

        it 'responds with success' do
          expect(response).to be_success
        end

        it 'does not assign an actionkit_user_id to the created Member' do
          expect(Member.first.actionkit_user_id).to be_blank
        end

        it 'sends the bad akid through the form data for record keeping' do
          expect(Action.where('form_data @> ?', { akid: invalid_akid }.to_json).first).to eq(page.actions.first)
        end

        it 'does not include a referring_user_uri in the queue message' do
          expected_params = hash_including(
            type: 'action',
            params: {
              page: 'foo-bar-petition',
              email: 'hello@example.com',
              page_id: page.id.to_s,
              form_id: form.id.to_s,
              akid: invalid_akid,
              action_mobile: 'unknown',
              action_referer: nil,
              user_en: 1
            }
          )

          expect(ChampaignQueue).to have_received(:push)
            .with(expected_params, group_id: /action:\d+/)
        end
      end
    end
  end
end
