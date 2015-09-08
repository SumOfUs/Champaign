require 'rails_helper'

describe ActionValidator do

  let(:form) { create :form }
  let(:element) { create :form_element, form: form, label: 'test' }

  before :each do
    @params = {form_id: element.form_id}
  end

  describe "errors and save" do

    describe "adds an error if" do

      after :each do
        expect(@validator.valid?).to eq false
      end
      
      describe "required field" do

        before :each do
          element.update_attributes({required: true})
        end

        after :each do
          @validator = ActionValidator.new(@params)
          expect(@validator.errors).to eq [['test', 'is required']]
        end

        it "does not appear" do
          @params.merge!({})
        end

        it "is nil" do
          @params.merge!({test: nil})
        end

        it "is false" do
          @params.merge!({test: false})
        end

        it "is empty string" do
          @params.merge!({test: ""})
        end
      end

      describe "email field" do
        it "is not a valid email"
      end

    end

    describe "does not add an error if" do

      after :each do
        @validator = ActionValidator.new(@params)
        expect(@validator.errors).to eq []
        expect(@validator.valid?).to eq true
      end

      describe "required field" do

        before :each do
          element.update_attributes({required: true})
        end

        it "is zero" do
          @params.merge!({test: 0})
        end

        it "is a string" do
          @params.merge!({test: ";) hey there"})
        end
      end

      describe "email" do
        it "is a valid email"
        it "is empty and not required"
      end
    end

  end

end
