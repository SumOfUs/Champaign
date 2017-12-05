# frozen_string_literal: true

require 'rails_helper'

describe 'API::MemberServices' do
  describe 'PUT /api/member_services/members/' do
    let!(:member) do
      create(:member,
             id: 3,
             email: 'test@sumofus.org',
             country: 'Belgium',
             first_name: 'Lydia',
             last_name: 'Testy',
             city: 'Brussels',
             postal: '123456',
             title: 'miss',
             address1: 'Some street',
             address2: 'Some address',
             actionkit_user_id: 'mega_akid',
             donor_status: 'donor',
             more: '{}')
    end

    # TODO: Move out auth headers specs from recurring_donations_spec.rb into its own file.
    context 'with valid auth headers' do
      let(:valid_headers) do
        {
          'X-CHAMPAIGN-SIGNATURE' => '2d39dea4bc00ceff1ec1fdf160540400f673e97474b1d197d240b084bd186d34',
          'X-CHAMPAIGN-NONCE' => 'd7b82ede-17f2-4e79-8377-0ad1a1dd8621'
        }
      end

      context 'given valid params' do
        let(:params) do
          {
            email: 'test@sumofus.org',
            first_name: 'Max',
            last_name: 'Testy-Smith',
            country: 'United Kingdom',
            postal: 'EC2 1AB'
          }
        end

        it 'updates the member details and sends back data' do
          put '/api/member_services/members/', params: params, headers: valid_headers
          expect(response.status).to eq 200
          expect(member.reload.updated_at).to be_within(0.1.seconds).of(Time.now)
          expect(json_hash.with_indifferent_access).to match(member: {
            id: 3,
            email: 'test@sumofus.org',
            first_name: 'Max',
            last_name: 'Testy-Smith',
            country: 'United Kingdom',
            postal: 'EC2 1AB',
            city: 'Brussels',
            title: 'miss',
            address1: 'Some street',
            address2: 'Some address',
            created_at: /\A\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}[.]\d{3}[a-zA-Z]\z/,
            updated_at: /\A\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}[.]\d{3}[a-zA-Z]\z/,
            actionkit_user_id: 'mega_akid',
            donor_status: 'donor',
            more: '{}'
          })
        end

        context 'when a member with the given email address does not exist' do
          let(:params) do
            {
              email: 'new_member@sumofus.org',
              first_name: 'Max',
              last_name: 'Testy-Smith',
              country: 'United Kingdom',
              postal: 'EC2 1AB'
            }
          end

          it 'logs error and sends back 404' do
            error_body = {
              errors:  [
                'No member associated with email address new_member@sumofus.org.'
              ]
            }

            put '/api/member_services/members/', params: params, headers: valid_headers
            expect(response.status).to eq 404
            expect(json_hash.with_indifferent_access).to match(error_body)
          end
        end

        context 'when the update fails' do
          let(:messed_up_member) do
            instance_double(Member, email: 'oemgee@sumofus.org')
          end

          it 'sends back errors and status 422' do
            allow(Member).to receive(:find_by_email).and_return(messed_up_member)
            allow(messed_up_member).to receive(:update_attributes).and_return(false)

            error_body = {
              errors: [
                'Updating member details failed for oemgee@sumofus.org.'
              ]
            }

            put '/api/member_services/members/', params: params, headers: valid_headers
            expect(response.status).to eq 422
            expect(json_hash.with_indifferent_access).to match(error_body)
          end
        end
      end
    end
  end
end
