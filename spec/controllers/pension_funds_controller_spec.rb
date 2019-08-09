require 'rails_helper'
RSpec.describe PensionFundsController, type: :controller do
  let(:valid_attributes) { FactoryBot.attributes_for(:pension_fund) }

  let(:invalid_attributes) {
    FactoryBot.attributes_for(:pension_fund, name: nil)
  }

  let(:user) { build(:user, email: 'test1@example.com') }
  let(:pension_fund) {
    PensionFund.order('RANDOM()').first
  }

  before do
    2.times { create(:pension_fund, country_code: 'AU') }
    3.times { create(:pension_fund, country_code: 'DK') }

    allow(request.env['warden']).to receive(:authenticate!) { user }
    allow(controller).to receive(:current_user) { user }
  end

  describe 'GET #index' do
    before { get :index }

    it { should respond_with(200)        }
    it { should render_template('index') }

    it 'should list out all 4 pension funds' do
      assigns(:pension_funds).size.should eq 5
    end
  end

  describe 'GET #index with filters' do
    context 'filter by country' do
      before { get :index, params: { country_code: 'AU' } }

      it { should respond_with(200)        }
      it { should render_template('index') }

      it 'should list out all 2 pension funds' do
        assigns(:pension_funds).size.should eq 2
      end
    end

    context 'filter by fund' do
      before do
        @fund = PensionFund.last
        get :index, params: { search_text: @fund.fund }
      end

      it { should respond_with(200)        }
      it { should render_template('index') }

      it 'should list out the pension fund' do
        assigns(:pension_funds).size.should eql 1
        assigns(:pension_funds).first.fund.should match @fund.fund
      end
    end

    context 'filter by email' do
      before do
        @fund = PensionFund.first
        get :index, params: { search_text: @fund.email }
      end

      it { should respond_with(200)        }
      it { should render_template('index') }

      it 'should list out the pension fund' do
        assigns(:pension_funds).size.should eql 1
        assigns(:pension_funds).first.email.should match @fund.email
      end
    end

    context 'filter by name' do
      before do
        @fund = PensionFund.first
        get :index, params: { search_text: @fund.name }
      end

      it { should respond_with(200)        }
      it { should render_template('index') }

      it 'should list out the pension fund' do
        assigns(:pension_funds).size.should eql 1
        assigns(:pension_funds).first.name.should match @fund.name
      end
    end

    context 'filter by country and name' do
      before do
        @fund = PensionFund.first
        get :index, params: { country_code: @fund.country_code, search_text: @fund.name }
      end

      it { should respond_with(200)        }
      it { should render_template('index') }

      it 'should list out the pension fund' do
        assigns(:pension_funds).size.should eql 1
        assigns(:pension_funds).first.name.should match @fund.name
      end
    end

    context 'filter by country and mismatching name' do
      before do
        @fund = PensionFund.first
        get :index, params: { country_code: 'DK', search_text: @fund.name }
      end

      it { should respond_with(200)        }
      it { should render_template('index') }

      it 'should not list any pension fund record' do
        assigns(:pension_funds).size.should eql 0
      end
    end
  end

  describe 'GET #new' do
    before { get :new }

    it { should respond_with(200)      }
    it { should render_template('new') }
  end

  describe 'GET #edit' do
    before do
      @fund = PensionFund.first
      get :edit, params: { id: @fund.to_param }
    end

    it { should respond_with(200)       }
    it { should render_template('edit') }

    it 'should pick proper record' do
      assigns(:pension_fund).name.should match @fund.name
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      before do
        post :create, params: { pension_fund: valid_attributes }
      end

      it { should redirect_to(action: :index) }

      it 'should create new pension fund' do
        PensionFund.count.should eql 6
      end
    end

    context 'with invalid params' do
      before do
        post :create, params: { pension_fund: invalid_attributes }
      end

      it { should render_template(:new) }

      it 'should not create new pension fund' do
        PensionFund.count.should eql 5
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      before do
        @fund = PensionFund.first
        post :update, params: { id: @fund.id, pension_fund: valid_attributes }
      end

      it { should redirect_to(action: :index) }

      it 'should update pension fund' do
        PensionFund.first.name.should match valid_attributes[:name]
      end
    end

    context 'with invalid params' do
      before do
        @fund = PensionFund.first
        post :update, params: { id: @fund.id, pension_fund: invalid_attributes }
      end

      it { should render_template(:edit) }

      it 'should not update pension fund' do
        PensionFund.first.name.should match @fund.name
      end
    end
  end
end
