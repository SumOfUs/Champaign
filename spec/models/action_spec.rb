require 'rails_helper'

describe Action do
  let(:page) { create :page }
  let(:member) { create :member }

  describe 'on create' do
    describe 'member donor_status' do

      describe 'when member is nondonor' do
        before :each do
          expect(member.donor_status).to eq 'nondonor'
        end

        it 'stays nondonor when action is not donation' do
          create :action, page: page, member: member, donation: false
          expect(member.reload.donor_status).to eq 'nondonor'
        end

        it 'becomes donor when action is non-recurring donation' do
          create :action, page: page, member: member, donation: true, form_data: {}
          expect(member.reload.donor_status).to eq 'donor'
        end

        it 'becomes recurring_donor when action is recurring donation' do
          create :action, page: page, member: member, donation: true, form_data: {is_subscription: true}
          expect(member.reload.donor_status).to eq 'recurring_donor'
        end
      end

      describe 'when member is donor' do
        before :each do
          member.donor!
          expect(member.donor_status).to eq 'donor'
        end

        it 'stays donor when action is not donation' do
          create :action, page: page, member: member, donation: false
          expect(member.reload.donor_status).to eq 'donor'
        end

        it 'stays donor when action is non-recurring donation' do
          create :action, page: page, member: member, donation: true, form_data: {}
          expect(member.reload.donor_status).to eq 'donor'
        end

        it 'becomes recurring_donor when action is recurring donation' do
          create :action, page: page, member: member, donation: true, form_data: {is_subscription: true}
          expect(member.reload.donor_status).to eq 'recurring_donor'
        end
      end

      describe 'when member is recurring_donor' do
        before :each do
          member.recurring_donor!
          expect(member.donor_status).to eq 'recurring_donor'
        end

        it 'stays recurring_donor when action is not donation' do
          create :action, page: page, member: member, donation: false
          expect(member.reload.donor_status).to eq 'recurring_donor'
        end

        it 'stays recurring_donor when action is non-recurring donation' do
          create :action, page: page, member: member, donation: true, form_data: {}
          expect(member.reload.donor_status).to eq 'recurring_donor'
        end

        it 'stays recurring_donor when action is recurring donation' do
          create :action, page: page, member: member, donation: true, form_data: {is_subscription: true}
          expect(member.reload.donor_status).to eq 'recurring_donor'
        end
      end
    end

    describe 'counter_cache on page' do

      subject{ create(:action, page_id: page.id, member_id: member.id) }

      it 'increases the action_count after creation' do
        expect { subject}.to change{ page.reload.action_count }.from(0).to(1)
      end

      it 'does not stamp updated_at' do
        expect { subject }.not_to change{ page.reload.updated_at }
      end

      it 'does not change cache_key' do
        expect { subject }.not_to change{ page.reload.cache_key }
      end
    end
  end
end

