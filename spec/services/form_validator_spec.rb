require 'rails_helper'

describe FormValidator do

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
          @validator = FormValidator.new(@params)
          expect(@validator.errors).to eq ({test: ['is required']})
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
          @validator = FormValidator.new(@params)
          expect(@validator.errors).to eq ({test: [I18n.t("validation.is_invalid_email")]})
        end

        it "is a basic sentence" do
          @params.merge!(test: "I'm not an email!")
        end

        it "is missing the TLD" do
          @params.merge!(test: "neal@sumofus")
        end

        it "has two @ symbols" do
          @params.merge!(test: "this@that@other.com")
        end
      end

      describe "phone" do

        before :each do
          element.update_attributes({data_type: "phone"})
        end

        after :each do
          @validator = FormValidator.new(@params)
          expect(@validator.errors).to eq ({test: [I18n.t("validation.is_invalid_phone")]})
        end

        it "is too short" do
          @params.merge!(test: "12345")
        end

        it "is only valid special characters" do
          @params.merge!(test: "(+) -- (+)")
        end
      end

      describe "country" do

        before :each do
          element.update_attributes({data_type: "country"})
        end

        after :each do
          @validator = FormValidator.new(@params)
          expect(@validator.errors).to eq ({test: [I18n.t("validation.is_invalid_country")]})
        end

        it "is a full country name" do
          @params.merge!(test: "Afghanistan")
        end

        it "is numbers" do
          @params.merge!(test: "33")
        end

        it "is lowercase" do
          @params.merge!(test: "gb")
        end
      end

    end

    describe "does not add an error if" do

      after :each do
        @validator = FormValidator.new(@params)
        expect(@validator.errors).to eq Hash.new
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

        it "is a valid email with multiple dots" do
          @params.merge!(test: "neal.donnelly@cycles.cs.princeton.edu")
        end

        it "is empty and not required" do
          @params.merge!({})
        end
      end

      describe "phone" do

        before :each do
          element.update_attributes({data_type: "phone"})
        end

        it "is all numbers" do
          @params.merge!(test: "123456790")
        end

        it "has spaces, dashes, pluses, and parentheses" do
          @params.merge!(test: "+1 (413)-555-1234")
        end

        it "is empty and not required" do
          @params.merge!({})
        end
      end

      describe "country" do

        before :each do
          element.update_attributes({data_type: "country"})
        end

        it "is all a known country code" do
          @params.merge!(test: "GB")
        end

        it "is empty and not required" do
          @params.merge!({})
        end
      end

    end

  end

end
