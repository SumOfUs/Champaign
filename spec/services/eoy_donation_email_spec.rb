# frozen_string_literal: true

require 'rails_helper'

describe EoyDonationEmail do
  describe '.opt_out' do
    context 'nil value' do
      subject { EoyDonationEmail.new(nil) }

      it 'should return error' do
        subject.opt_out
        expect(subject.errors.full_messages.first).to include("Member can't be blank")
      end
    end

    context 'new member object' do
      subject { EoyDonationEmail.new(Member.new) }

      it 'should return error' do
        subject.opt_out
        expect(subject.errors.full_messages.first).to include('member does not have actionkit id')
      end
    end

    context 'valid member with action kit id' do
      let(:member) { create(:member) }
      subject { EoyDonationEmail.new(member) }

      before do
        EoyDonationEmail.any_instance.stub(:sync_with_action_kit).and_return(true)
      end

      it 'should return true' do
        expect(subject.opt_out).to eql true
        expect(subject.errors).to be_empty
        expect(subject.member.opt_out_eoy_donation).to eql 1
      end
    end

    context 'action kit sync failed' do
      let(:member) { create(:member, opt_out_eoy_donation: 0) }
      subject { EoyDonationEmail.new(member) }

      before do
        subject.stub(:sync_with_action_kit).and_return(false)
      end

      it 'should return false' do
        expect(subject.opt_out).to eql false
        expect(subject.errors).to be_empty
        subject.member.reload
        expect(subject.member.opt_out_eoy_donation).to eql 0
      end
    end
  end

  describe '.opt_in' do
    context 'nil value' do
      subject { EoyDonationEmail.new(nil) }

      it 'should return error' do
        subject.opt_in
        expect(subject.errors.full_messages.first).to include("Member can't be blank")
      end
    end

    context 'new member object' do
      subject { EoyDonationEmail.new(Member.new) }

      it 'should return error' do
        subject.opt_in
        expect(subject.errors.full_messages.first).to include('member does not have actionkit id')
      end
    end

    context 'valid member with action kit id' do
      let(:member) { create(:member, opt_out_eoy_donation: 1) }
      subject { EoyDonationEmail.new(member) }

      before do
        EoyDonationEmail.any_instance.stub(:sync_with_action_kit).and_return(true)
      end

      it 'should return true' do
        expect(subject.opt_in).to eql true
        expect(subject.errors).to be_empty
        expect(subject.member.opt_out_eoy_donation).to eql 0
      end
    end

    context 'action kit sync failed' do
      let(:member) { create(:member, opt_out_eoy_donation: 1) }
      subject { EoyDonationEmail.new(member) }

      before do
        EoyDonationEmail.any_instance.stub(:sync_with_action_kit).and_return(false)
      end

      it 'should return false' do
        expect(subject.opt_out).to eql false
        expect(subject.errors).to be_empty
        expect(subject.member.opt_out_eoy_donation).to eql 1
      end
    end
  end
end
