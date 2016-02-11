require 'rails_helper'

describe FormValidator do

  let(:form) { create :form }

  subject { FormValidator.new(params) }

  context "with required as true" do
    let(:element) { create :form_element, form: form, required: true, label: 'Address', name: 'address1' }
    let(:params){ {form_id: element.form_id} }

    it "is valid with value" do
      params.merge!(address1: 'foo')
      expect(subject).to be_valid
    end

    it 'is valid with value and string key' do
      params.merge!('address1' => 'bar')
      expect(subject).to be_valid
    end

    context "is invalid" do
      it "without value" do
        expect(subject).to_not be_valid
      end

      it "with nil" do
        params.merge!(address1: nil)
        expect(subject).to_not be_valid
      end

      it "with false" do
        params.merge!(address1: false)
        expect(subject).to_not be_valid
      end

      it "with empty string" do
        params.merge!(address1: "")
        expect(subject).to_not be_valid
      end
    end
  end

  context "with email as data_type" do
    let(:element) { create :form_element, :email, form: form }
    let(:params){ {form_id: element.form_id, email: 'foo@example.com' } }

    context "is valid" do
      it "with regular address" do
        expect(subject).to be_valid
      end

      it "with multiple dots" do
        params.merge!(email: "neal.donnelly@cycles.cs.princeton.edu")
        expect(subject).to be_valid
      end
    end

    context "is invalid" do
      it "with a basic sentence" do
        params.merge!(email: "I'm not an email!")
        expect(subject).to_not be_valid
      end

      it "with missing the TLD" do
        params.merge!(email: "neal@sumofus")
        expect(subject).to_not be_valid
      end

      it "with two @ symbols" do
        params.merge!(email: "this@that@other.com")
        expect(subject).to_not be_valid
      end
    end
  end

  context "with phone as data_type" do
    let(:element) { create :form_element, :phone, form: form }
    let(:params){ {form_id: element.form_id, phone: '00 2323 12345' } }

    context "is valid" do
      it "with regular numbers" do
        expect(subject).to be_valid
      end

      it "has spaces, dashes, pluses, and parentheses" do
        params.merge!(phone: "+1 (413)-555-1234")
        expect(subject).to be_valid
      end
    end

    context "is invalid" do
      it "if too short" do
        params.merge!(phone: "12345")
        expect(subject).to_not be_valid
      end

      it "with invalid special characters" do
        params.merge!(phone: "(+) -- (+)")
        expect(subject).to_not be_valid
      end
    end
  end

  context "with country as data_type" do
    let(:element) { create :form_element, :country, form: form }
    let(:params){ { form_id: element.form_id, country: 'FR' } }

    it "is valid" do
      expect(subject).to be_valid
    end

    context "is invalid" do
      it "with full country name" do
        params.merge!(country: "France")
        expect(subject).to_not be_valid
      end

      it "with a number" do
        params.merge!(country: "33")
        expect(subject).to_not be_valid
      end

      it "as lowercase" do
        params.merge!(country: "fr")
        expect(subject).to_not be_valid
      end
    end
  end

  context 'with zip as data type' do
    let(:element) { create :form_element, :postal, form: form }
    let(:country_element) { create :form_element, :country, form: form}
    let(:us_zip) { '12345' }
    let(:uk_zip) { 'CR0 3RL' }
    let(:params) { { form_id: element.form_id, postal: us_zip } }

    context 'is valid' do
      it 'without a country code' do
        expect(subject).to be_valid
      end

      it 'with a valid country code in the UK' do
        params.merge!(postal: uk_zip, country: :UK)
        expect(subject).to be_valid
      end
    end

    context 'is invalid' do
      it 'with an incorrect code' do
        params.merge!(postal: 'Not a valid zip')
        expect(subject).to_not be_valid
      end

      it 'with a valid code but incorrect country code' do
        country_element
        params.merge!(country: :UK)
        expect(subject).to_not be_valid
      end
    end
  end
end

