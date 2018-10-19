# frozen_string_literal: true

require 'rails_helper'

describe 'Double opt-in' do
  let(:params) do
    {
      email:    'hello@example.com',
      form_id:  form.id,
      source:   'fb',
      country:  'DE',
      name: 'John Doe'
    }
  end

  describe 'creating an action' do
    let(:pending_action) { PendingAction.last }
    let(:form) { create(:form_with_email_and_optional_country) }

    context 'without petiton plugin' do
      let(:page) {
        create(:page, :with_call_tool, title: 'Foo Bar',
                                       slug: 'foo-bar',
                                       language: create(:language, :german))
      }

      it 'does not record a pending action' do
        post "/api/pages/#{page.id}/actions", params: params
        expect(pending_action).to be nil
      end
    end

    context 'with petition plugin' do
      let(:page) {
        create(:page, :with_petition, title: 'Foo Bar',
                                      slug: 'foo-bar',
                                      follow_up_liquid_layout: create(:liquid_layout),
                                      language: create(:language, :german))
      }

      let(:client) { double }

      before do
        allow(Aws::SNS::Client).to receive(:new) { client }
        allow(client).to receive(:publish)
      end

      context 'with existing member' do
        let!(:member) { create(:member, email: 'hello@example.com') }

        context 'without consent' do
          before do
            member.update(consented: false)
          end

          it 'creates pending action' do
            post "/api/pages/#{page.id}/actions", params: params
            expect(pending_action.email).to eq('hello@example.com')
          end
        end

        context 'with consent' do
          before do
            member.update(consented: true)
          end

          it 'does not create a pending action' do
            post "/api/pages/#{page.id}/actions", params: params
            expect(pending_action).to be nil
          end
        end
      end

      it 'records email address' do
        post "/api/pages/#{page.id}/actions", params: params
        expect(pending_action.email).to eq('hello@example.com')
      end

      it 'increments email count (number of confirmation emails sent)' do
        post "/api/pages/#{page.id}/actions", params: params
        expect(pending_action.email_count).to eq(1)
      end

      it 'triggers an sns event' do
        post "/api/pages/#{page.id}/actions", params: params

        expect(client).to have_received(:publish).with(
          hash_including(
            message: /token=#{PendingAction.last.token}/
          )
        )
      end

      it 'records when email was sent' do
        Timecop.freeze do
          @now = Time.now.utc
          post "/api/pages/#{page.id}/actions", params: params
          expect(pending_action.emailed_at.to_s).to eq(@now.to_s)
        end
      end

      it 'redirects to follow up' do
        post "/api/pages/#{page.id}/actions", params: params
        resp = {
          follow_up_url: '/a/foo-bar/follow-up?double_opt_in=true',
          double_opt_in: true
        }

        expect(response.body).to eq(resp.to_json)
      end
    end
  end
end
