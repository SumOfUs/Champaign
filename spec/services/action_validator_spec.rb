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
          @params.merge!(test: nil)
        end

        it "is false" do
          @params.merge!(test: false)
        end

        it "is empty string" do
          @params.merge!(test: "")
        end
      end

      describe "email field" do

        before :each do
          element.update_attributes({data_type: "email"})
        end

        after :each do
          @validator = ActionValidator.new(@params)
          expect(@validator.errors).to eq [['test', 'must be a valid email']]
        end

        it "is not a valid email" do
          @params.merge!(test: "I'm not an email!")
        end
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
          @params.merge!(test: 0)
        end

        it "is a string" do
          @params.merge!(test: ";) hey there")
        end
      end

      describe "email" do

        before :each do
          element.update_attributes({data_type: "email"})
        end

        it "is a valid email" do
          @params.merge!(test: "neal@sumofus.org")
        end

        it "is empty and not required" do
          @params.merge!({})
        end
      end
    end

  end

end
