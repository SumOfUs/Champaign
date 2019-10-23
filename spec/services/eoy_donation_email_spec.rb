# frozen_string_literal: true

require 'rails_helper'

describe EoyDonationEmail do
  let(:ak_raw_id) { "#{Settings.action_kit.akid_secret}.2678.323423423999" }
  let(:ak_hash) { Base64.urlsafe_encode64(Digest::SHA256.digest(ak_raw_id))[0..5] }
  let(:akid) { "2678.323423423999.#{ak_hash}" }

  describe '.opt_out' do
    context 'nil value' do
      subject { EoyDonationEmail.new(nil) }

      it 'should return error' do
        subject.opt_out
        errors = subject.errors.full_messages
        expect(errors).to match_array(["Akid can't be blank", "Actionkit user can't be blank"])
      end
    end

    context 'member without local actionkit id' do
      let(:member) { create :member, actionkit_user_id: nil }
      subject { EoyDonationEmail.new(akid) }

      it 'should return true when opt_out' do
        stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])
        expect(subject.opt_out).to eql true
        expect(subject.member).to eql nil
      end
    end

    context 'member with local actionkit id' do
      before do
        create :member, actionkit_user_id: '323423423999'
        stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])
      end

      subject { EoyDonationEmail.new(akid) }

      it 'should return true' do
        expect(subject.opt_out).to eql true
        expect(subject.member.opt_out_eoy_donation).to eql 1
      end
    end

    context 'actionkit update failed' do
      before do
        create :member, actionkit_user_id: '323423423999'
        stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [404, 'Not Found'])
      end

      subject { EoyDonationEmail.new(akid) }

      it 'should return false' do
        expect(subject.opt_out).to eql false
        expect(subject.errors.full_messages).to include('Error updating actionkit')
        expect(subject.member.opt_out_eoy_donation).to eql 0
      end
    end
  end

  describe '.opt_in' do
    context 'nil value' do
      subject { EoyDonationEmail.new(nil) }

      it 'should return error' do
        subject.opt_in
        errors = subject.errors.full_messages
        expect(errors).to match_array(["Akid can't be blank", "Actionkit user can't be blank"])
      end
    end

    context 'member without local actionkit id' do
      let(:member) { create :member, actionkit_user_id: nil }
      subject { EoyDonationEmail.new(akid) }

      it 'should return true when opt_out' do
        stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])
        expect(subject.opt_in).to eql true
        expect(subject.member).to eql nil
      end
    end

    context 'member with local actionkit id' do
      before do
        create :member, actionkit_user_id: '323423423999', opt_out_eoy_donation: 1
        stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [204, 'No Content'])
      end

      subject { EoyDonationEmail.new(akid) }

      it 'should return true' do
        expect(subject.opt_in).to eql true
        expect(subject.member.opt_out_eoy_donation).to eql 0
      end
    end

    context 'actionkit update failed' do
      before do
        create :member, actionkit_user_id: '323423423999', opt_out_eoy_donation: 1
        stub_request(:any, /#{Settings.ak_api_url}/).to_return(status: [404, 'Not Found'])
      end

      subject { EoyDonationEmail.new(akid) }

      it 'should return false' do
        expect(subject.opt_in).to eql false
        expect(subject.errors.full_messages).to include('Error updating actionkit')
        expect(subject.member.opt_out_eoy_donation).to eql 1
      end
    end
  end
end
