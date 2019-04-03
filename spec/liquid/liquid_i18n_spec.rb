# frozen_string_literal: true

require 'rails_helper'

describe LiquidI18n do
  # to define a liquid filter, you make a module with instance methods that
  # gets included by liquid. You can't make them module_functions, so here
  # we extend a generic class to call the filter
  subject { Class.new.extend(LiquidI18n) }

  before :all do
    translations = {
      'liquidi18nspec' => {
        'basic' => 'Super simple',
        'temperature' => 'It is %{temp} degrees',
        'two' => 'First you %{one} then you %{two}',
        'ten' => '%{a} - %{b} - %{c} - %{d} - %{e} - %{f} - %{g} - %{h} - %{i} - %{j}',
        'eleven' => '%{a} - %{b} - %{c} - %{d} - %{e} - %{f} - %{g} - %{h} - %{i} - %{j} - %{k}',
        'variety' => '%{one} for the %{money}, %{two} for the %{show}, %{three} to get ready and four to go!'
      }
    }
    I18n.backend.store_translations('en', translations)
  end

  describe 't' do
    it 'translates without interpolation' do
      expect(subject.t('liquidi18nspec.basic')).to eq 'Super simple'
    end

    it 'correctly interpolates one value with spaces' do
      expect(
        subject.t('liquidi18nspec.temperature, temp: 15')
      ).to eq 'It is 15 degrees'
    end

    it 'correctly interpolates one value without spaces' do
      expect(
        subject.t('liquidi18nspec.temperature,temp:15')
      ).to eq 'It is 15 degrees'
    end

    it 'correctly interpolates two values' do
      expect(
        subject.t('liquidi18nspec.two, one: :) and ;), two: smile and wink')
      ).to eq 'First you :) and ;) then you smile and wink'
    end

    it 'correctly interpolates ten values' do
      expect(
        subject.t('liquidi18nspec.ten, a: q, b: w, c: e, d: r, e: t, f: y, g: u, h: i, i: o, j: p')
      ).to eq 'q - w - e - r - t - y - u - i - o - p'
    end

    it 'will not interpolate more than ten values' do
      expect do
        subject.t('liquidi18nspec.ten, a: q, b: w, c: e, d: r, e: t, f: y, g: u, h: i, i: o, j: p, k: p')
      end.to raise_error I18n::TooMuchInterpolation
    end

    it 'can interpolate punctuation, numbers, and accents' do
      expect(
        subject.t('liquidi18nspec.variety, one: In it, money: $$ dollas $$, two: ráce, show: finish, three: 3')
      ).to eq 'In it for the $$ dollas $$, ráce for the finish, 3 to get ready and four to go!'
    end

    it 'handles a case with no commas' do
      expect do
        subject.t('liquidi18nspec.temperature temp: 15')
      end.to raise_error I18n::TranslationMissing
    end

    it 'handles a case with too many commas and colons' do
      expect(
        subject.t('liquidi18nspec.temperature, ,womp, temp:15, ::15, womp:temp')
      ).to eq 'It is 15 degrees'
    end

    describe 'handles a missing translation' do
      it 'by raising an error in test' do
        expect(Rails.env.test?).to eq true
        expect { subject.t('fundraiser.lunacy') }.to raise_error I18n::TranslationMissing
      end

      it 'by raising an error in development' do
        allow(Rails).to receive(:env).and_return 'development'.inquiry
        expect(Rails.env.development?).to eq true
        expect { subject.t('fundraiser.lunacy') }.to raise_error I18n::TranslationMissing
      end

      it 'by showing the best effort on production' do
        allow(Rails).to receive(:env).and_return 'production'.inquiry
        expect(Rails.env.production?).to eq true
        expect { subject.t('fundraiser.lunacy') }.not_to raise_error
        expect(subject.t('fundraiser.lunacy')).to eq 'translation missing: en.fundraiser.lunacy'
      end
    end
  end

  describe 'val' do
    it 'can append one value pair' do
      expect(subject.val('rebel-bass', 'king', 'pin')).to eq 'rebel-bass, king: pin'
    end

    it 'nests nicely' do
      expect(subject.val(subject.val('rebel-bass', 'king', 'pin'), 'time', 'flies')).to eq 'rebel-bass, king: pin, time: flies'
    end
  end

  describe '#date_for_link' do
    {
      en: '1 December 2016',
      fr: '1 décembre 2016',
      de: '1. Dezember 2016'
    }.each do |locale, translation|
      it "localises date for #{locale}" do
        I18n.locale = locale

        expect(
          subject.i18n_date('2016-12-01')
        ).to eq(translation)
      end
    end
  end
end
