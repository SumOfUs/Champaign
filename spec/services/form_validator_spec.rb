# frozen_string_literal: true
require 'rails_helper'

describe FormValidator do
  shared_examples 'is correctly validated' do
    let(:form) { create :form }

    context 'with required as true' do
      let!(:element) do
        create :form_element, form: form, required: true, label: 'Address', name: 'address1'
      end
      let(:params) { {} }

      it 'is valid with value' do
        params[:address1] = 'foo'
        expect(subject).to be_valid
      end

      it 'is valid with value and string key' do
        params['address1'] = 'bar'
        expect(subject).to be_valid
      end

      context 'is invalid' do
        it 'without value' do
          expect(subject).to_not be_valid
        end

        it 'with nil' do
          params[:address1] = nil
          expect(subject).to_not be_valid
        end

        it 'with false' do
          params[:address1] = false
          expect(subject).to_not be_valid
        end

        it 'with empty string' do
          params[:address1] = ''
          expect(subject).to_not be_valid
        end

        it 'with paragraph data type and empty string' do
          element.update_attributes(data_type: 'paragraph')
          params[:address1] = ''
          expect(subject).to_not be_valid
        end
      end
    end

    context 'with checkbox as data_type' do
      let!(:element) { create :form_element, :checkbox, form: form, required: true, name: 'action_box_agrees' }
      let(:params) { {} }

      it 'is valid with value 1' do
        params[:action_box_agrees] = 1
        expect(subject).to be_valid
      end

      it 'is valid with string value' do
        params[:action_box_agrees] = 'true'
        expect(subject).to be_valid
      end

      it 'is invalid when nil' do
        params[:action_box_agrees] = nil
        expect(subject).not_to be_valid
      end

      it 'is invalid when not included' do
        expect(subject).not_to be_valid
      end

      it 'is invalid when number 0' do
        params[:action_box_agrees] = 0
        expect(subject).not_to be_valid
      end

      it 'is invalid when string 0' do
        params[:action_box_agrees] = '0'
        expect(subject).not_to be_valid
      end
    end

    context 'with email as data_type' do
      let!(:element) { create :form_element, :email, form: form }
      let(:params) { { email: 'foo@example.com' } }

      context 'is valid' do
        it 'with regular address' do
          expect(subject).to be_valid
        end

        it 'with multiple dots' do
          params[:email] = 'neal.donnelly@cycles.cs.princeton.edu'
          expect(subject).to be_valid
        end
      end

      context 'is invalid' do
        it 'with a basic sentence' do
          params[:email] = "I'm not an email!"
          expect(subject).to_not be_valid
        end

        it 'with missing the TLD' do
          params[:email] = 'neal@sumofus'
          expect(subject).to_not be_valid
        end

        it 'with two @ symbols' do
          params[:email] = 'this@that@other.com'
          expect(subject).to_not be_valid
        end

        it 'with ascii' do
          params[:email] = "this\xC2@other.com"
          expect(subject).to_not be_valid
        end

        it 'with a dot just before the @' do
          params[:email] = 'this.@other.com'
          expect(subject).to_not be_valid
        end

        it 'with a two consecutive dots' do
          params[:email] = 'thi..s@other..com'
          expect(subject).to_not be_valid
        end
      end
    end

    context 'with phone as data_type' do
      let!(:element) { create :form_element, :phone, form: form }
      let(:params) { { phone: '00 2323 12345' } }

      context 'is valid' do
        it 'with regular numbers' do
          expect(subject).to be_valid
        end

        it 'has spaces, dashes, pluses, and parentheses' do
          params[:phone] = '+1 (413)-555-1234'
          expect(subject).to be_valid
        end
      end

      context 'is invalid' do
        it 'if too short' do
          params[:phone] = '12345'
          expect(subject).to_not be_valid
        end

        it 'with invalid special characters' do
          params[:phone] = '(+) -- (+)'
          expect(subject).to_not be_valid
        end
      end
    end

    context 'with country as data_type' do
      let!(:element) { create :form_element, :country, form: form }
      let(:params) { { country: 'FR' } }

      it 'is valid' do
        expect(subject).to be_valid
      end

      context 'is invalid' do
        it 'with full country name' do
          params[:country] = 'France'
          expect(subject).to_not be_valid
        end

        it 'with a number' do
          params[:country] = '33'
          expect(subject).to_not be_valid
        end

        it 'as lowercase' do
          params[:country] = 'fr'
          expect(subject).to_not be_valid
        end
      end
    end

    context 'with zip as data type' do
      let!(:element) { create :form_element, :postal, form: form }
      let(:country_element) { create :form_element, :country, form: form }
      let(:us_postal) { '12345' }
      let(:uk_postal) { 'CR0 3RL' }
      let(:params) { { postal: us_postal } }

      context 'is valid' do
        it 'without a country code' do
          expect(subject).to be_valid
        end

        it 'with a valid country code in the UK' do
          params.merge!(postal: uk_postal, country: :UK)
          expect(subject).to be_valid
        end
      end

      context 'is invalid' do
        it 'with an incorrect code' do
          params[:postal] = 'Not a valid zip'
          expect(subject).to_not be_valid
        end

        it 'with a valid code but incorrect country code' do
          country_element
          params[:country] = :UK
          expect(subject).to_not be_valid
        end
      end
    end

    context 'with text as data type' do
      let!(:element) { create :form_element, form: form, required: false, label: 'Address', name: 'address1' }
      let(:params) { { address1: 'b' * 249 } }

      it 'is valid with a 249 character string' do
        expect(subject.errors).to be_empty
      end

      it 'is invalid with a 250 character string' do
        params[:address1] = 'b' * 250
        expect(subject.errors).not_to be_empty
        expect(subject.errors[:address1].first).to match(/less than 250/)
      end
    end

    context 'with comment as data type' do
      let!(:element) do
        create :form_element, :paragraph, form: form, required: false, label: 'Address', name: 'address1'
      end
      let(:params) { { address1: 'b' * 9_999 } }

      it 'is valid with a 9,999 character string' do
        expect(subject.errors).to be_empty
      end

      it 'is valid with a nil when element not required' do
        params[:address1] = nil
        expect(subject.errors).to be_empty
      end

      it 'is valid with an empty string when element not required' do
        params[:address1] = ''
        expect(subject.errors).to be_empty
      end

      it 'is invalid with a 10,000 character string' do
        params[:address1] = 'b' * 10_000
        expect(subject.errors).not_to be_empty
        expect(subject.errors[:address1].first).to match(/less than 10000/)
      end
    end
  end

  context 'passing a form id' do
    subject { FormValidator.new(params.merge(form_id: element.form_id)) }

    include_examples 'is correctly validated'
  end

  context 'passing hashes' do
    let(:hash_els) do
      form.form_elements.map do |el|
        { name: el.name, required: el.required?, data_type: el.data_type }
      end
    end

    subject { FormValidator.new(params, hash_els) }

    include_examples 'is correctly validated'
  end
end
