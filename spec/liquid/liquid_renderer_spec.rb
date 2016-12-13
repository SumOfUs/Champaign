# frozen_string_literal: true
require 'rails_helper'

describe LiquidRenderer do
  let!(:body_partial) { create :liquid_partial, title: 'body_text', content: '<p>{{ content }}</p>' }
  let(:liquid_layout) { create :liquid_layout, content: "<h1>{{ title }}</h1> {% include 'body_text' %}" }
  let(:page)          { create :page, liquid_layout: liquid_layout, content: 'sliiiiide to the left' }
  let(:renderer)      { LiquidRenderer.new(page) }
  let(:cache_helper)  { double(:cache_helper, key_for_data: 'foo', key_for_markup: 'bar') }

  describe 'new' do
    it 'receives the correct arguments' do
      expect do
        LiquidRenderer.new(page, location: {}, member: {}, url_params: { hi: 'a' })
      end.not_to raise_error
    end

    it 'requires only page and layout' do
      expect do
        LiquidRenderer.new(page)
      end.not_to raise_error
    end

    it 'does not receive arbitrary keyword arguments' do
      expect do
        LiquidRenderer.new(page, follow_up_layout: liquid_layout)
      end.to raise_error(ArgumentError)
    end

    describe 'setting locale' do
      describe 'leaves english as the locale when page' do
        it 'has no language' do
          page.language = nil
          LiquidRenderer.new(page)
          expect(I18n.locale).to eq :en
          expect(I18n.t('common.save')).to eq 'Save'
        end

        it 'has a nonsense language code' do
          page.language = build :language, code: 'xxx'
          LiquidRenderer.new(page)
          expect(I18n.locale).to eq :en
          expect(I18n.t('common.save')).to eq 'Save'
        end

        it 'has an unsupported language code' do
          page.language = build :language, code: 'es'
          LiquidRenderer.new(page)
          expect(I18n.locale).to eq :en
          expect(I18n.t('common.save')).to eq 'Save'
        end
      end
    end
  end

  describe 'render' do
    it 'returns an html string with the title' do
      expect(renderer.render).to include("<h1>#{page.title}</h1>")
    end

    it 'renders the partial with the content' do
      expect(renderer.render).to include("<p>#{page.content}</p>")
    end

    describe 'handles a missing translation' do
      it 'by raising an error in test' do
        expect(Rails.env.test?).to eq true
        liquid_layout.update_attributes(content: "{{ 'fundraiser.lunacy' | t }}")
        expect { renderer.render }.to raise_error I18n::TranslationMissing
      end

      it 'by raising an error in development' do
        allow(Rails).to receive(:env).and_return 'development'.inquiry
        expect(Rails.env.development?).to eq true
        liquid_layout.update_attributes(content: "{{ 'fundraiser.lunacy' | t }}")
        expect { renderer.render }.to raise_error I18n::TranslationMissing
      end

      it 'by showing the best effort on production' do
        allow(Rails).to receive(:env).and_return 'production'.inquiry
        expect(Rails.env.production?).to eq true
        liquid_layout.update_attributes(content: "{{ 'fundraiser.lunacy' | t }}")
        expect { renderer.render }.not_to raise_error
        expect(renderer.render).to include('lunacy')
      end
    end

    it 'fills in localized string' do
      liquid_layout.update_attributes(content: "{{ 'common.confirm' | t }}")
      expect(renderer.render).to eq 'Are you sure?'
    end
  end

  describe 'default_markup' do
    it 'is not a method' do
      expect(renderer).not_to respond_to(:default_markup)
    end
  end

  describe 'markup_data' do
    let(:page) do
      create(:page,
             follow_up_liquid_layout: create(:liquid_layout),
             follow_up_page:          create(:page))
    end
    let(:fake_images) do
      [instance_double(Image, content: nil, content_file_name: 'smile.jpg'),
       instance_double(Image, content: nil, content_file_name: 'hearts.png')]
    end
    let(:empty_img_hash) { { 'urls' => { 'large' => '', 'small' => '', 'original' => '' } } }

    subject { renderer.send(:markup_data) }

    it 'has string keys' do
      expect(subject.keys.map(&:class).uniq).to eq [String]
    end

    it 'has expected keys' do
      expected_keys = %w(
        plugins
        ref
        images
        named_images
        shares
        country_option_tags
        follow_up_url
        primary_image
        petition_target
        locale
      )

      expected_keys += page.liquid_data.keys.map(&:to_s)

      expect(subject.keys).to match_array(expected_keys)
    end

    it 'has a follow_up_url' do
      expect(subject.fetch('follow_up_url')).to match(%r{a\/[a-z0-9\-]+\/follow\-up})
    end

    it 'gives image urls in a list for images' do
      allow(page).to receive(:images).and_return(fake_images)
      expect(subject['images']).to eq [empty_img_hash, empty_img_hash]
    end

    it 'gives image urls in a hash for named_images' do
      allow(page).to receive(:images).and_return(fake_images)
      expect(subject['named_images']).to eq('smile' => empty_img_hash, 'hearts' => empty_img_hash)
    end
  end

  describe 'personalization_data' do
    it 'should have string keys' do
      expect(renderer.personalization_data.keys.map(&:class).uniq).to eq [String]
    end

    it 'should have expected keys' do
      expected_keys = %w(
        url_params
        outstanding_fields
        location
        member
        donation_bands
        thermometer
        action_count
        show_direct_debit
        payment_methods
        form_values
      )
      actual_keys = renderer.personalization_data.keys
      expect(actual_keys).to match_array(expected_keys)
    end

    describe 'show_direct_debit' do
      let(:location) { instance_double('Geocoder::Result::Freegeoip', data: { country_code: 'US' }, country_code: 'US') }
      let(:member) { build :member, country: 'DE' }
      let(:form) { create :form_with_email_and_name }
      let(:fundraiser) { create :plugins_fundraiser, page: page, form: form }

      before :each do
        create :plugins_fundraiser, page: page, form: form, recurring_default: 'recurring'
        allow(DirectDebitDecider).to receive(:decide).and_return(true)
      end

      it 'calls DirectDebitDecider with url_params[:recurring_default] if both present' do
        LiquidRenderer.new(page, member: member, url_params: { recurring_default: 'one_off' }).personalization_data
        expect(DirectDebitDecider).to have_received(:decide).with([nil, 'DE'], 'one_off')
      end

      it 'calls DirectDebitDecider with fundraiser.recurring_default if no url_params[:recurring_default]' do
        LiquidRenderer.new(page, member: member).personalization_data
        expect(DirectDebitDecider).to have_received(:decide).with([nil, 'DE'], 'recurring')
      end

      it 'calls DirectDebitDecider with location country and member country' do
        LiquidRenderer.new(page, member: member, location: location).personalization_data
        expect(DirectDebitDecider).to have_received(:decide).with(%w(US DE), 'recurring')
      end
    end

    describe 'outstanding_fields' do
      it 'is [] if it has no plugins' do
        expect(page.plugins.size).to eq 0
        expect(LiquidRenderer.new(page).personalization_data['outstanding_fields']).to eq []
      end

      it "is [] if it's plugins don't have forms" do
        create :plugins_thermometer, page: page
        expect(LiquidRenderer.new(page).personalization_data['outstanding_fields']).to eq []
      end

      it 'has the fields from one plugin form' do
        form = create :form_with_email_and_name
        create :plugins_fundraiser, page: page, form: form
        expect(LiquidRenderer.new(page).personalization_data['outstanding_fields']).to eq %w(email name)
      end

      it "checks with the member's liquid data" do
        form = create :form_with_email_and_name
        fundraiser = create :plugins_fundraiser, page: page, form: form
        member = create :member, name: 'Humphrey Bogart', email: 'psycho@killer.com'
        expect(member.liquid_data.keys).to include(:name)
        expect(member.attributes.keys).not_to include(:name)
        expect(LiquidRenderer.new(page, member: member).personalization_data['outstanding_fields']).to eq []
      end

      it 'has from both plugin forms' do
        p1 = create :plugins_fundraiser, page: page
        p2 = create :plugins_petition, page: page
        p1.update_attributes(form: create(:form_with_email_and_name))
        p2.update_attributes(form: create(:form_with_phone_and_country))
        expect(LiquidRenderer.new(page).personalization_data['outstanding_fields']).to match_array %w(email name phone country)
      end
    end

    describe 'donation_bands' do
      let(:stubbed_amounts) { [1, 2, 3, 4, 5] }
      let(:stubbed_conversion) do
        %w(GBP EUR AUD NZD CAD).inject({}) do |memo, a|
          memo[a] = stubbed_amounts
          memo
        end
      end

      before :each do
        allow(PaymentProcessor::Currency).to receive(:convert)
      end

      it 'is nil if it has no plugins and no url_params' do
        expect(page.plugins.size).to eq 0
        expect(LiquidRenderer.new(page).personalization_data['donation_bands']).to eq nil
      end

      it "is {} if it's plugins don't have donation bands and no url_params" do
        fundraiser = create :plugins_fundraiser, page: page
        expect(fundraiser.donation_band).to eq nil
        expect(LiquidRenderer.new(page).personalization_data['donation_bands']).to eq({})
      end

      it "has the fundraiser's donation band if no url_param" do
        a = create :donation_band, name: 'eh mate'
        b = create :donation_band, name: 'bee boy'
        create :plugins_fundraiser, page: page, donation_band: b
        expected = { 'USD' => Donations::Utils.round_and_dedup(b.amounts.map { |v| v / 100 }) }
        expect(LiquidRenderer.new(page).personalization_data['donation_bands']).to eq stubbed_conversion.merge(expected)
      end

      it "has the first fundraiser's donation band if multiple" do
        a = create :donation_band, name: 'eh mate'
        b = create :donation_band, name: 'bee boy'
        create :plugins_fundraiser, page: page, donation_band: a
        create :plugins_fundraiser, page: page, donation_band: b
        expected = { 'USD' => Donations::Utils.round_and_dedup(b.amounts.map { |v| v / 100 }) }
        expect(LiquidRenderer.new(page).personalization_data['donation_bands']).to eq stubbed_conversion.merge(expected)
      end

      it "has the fundraiser's donation band if url_param nonsensical" do
        a = create :donation_band, name: 'eh mate'
        b = create :donation_band, name: 'bee boy'
        create :plugins_fundraiser, page: page, donation_band: b
        expected = { 'USD' => Donations::Utils.round_and_dedup(b.amounts.map { |v| v / 100 }) }
        expect(LiquidRenderer.new(page, url_params: { donation_band: 'slurp' }).personalization_data['donation_bands']).to eq stubbed_conversion.merge(expected)
      end

      it 'uses the url_params donation band if passed' do
        a = create :donation_band, name: 'eh mate'
        b = create :donation_band, name: 'bee boy'
        create :plugins_fundraiser, page: page, donation_band: b
        expected = { 'USD' => Donations::Utils.round_and_dedup(a.amounts.map { |v| v / 100 }) }
        expect(LiquidRenderer.new(page, url_params: { donation_band: a.name }).personalization_data['donation_bands']).to eq stubbed_conversion.merge(expected)
      end
    end

    describe 'location' do
      let(:location) { instance_double('Geocoder::Result::Freegeoip', data: { country_code: 'US' }, country_code: 'US') }

      before :each do
        allow(Donations::Utils).to receive(:currency_from_country_code) { 'USD' }
      end

      it 'returns the location its passed' do
        allow(location).to receive(:data) { { region: 'USA' } }
        allow(location).to receive(:country_code) { nil }
        renderer = LiquidRenderer.new(page, location: location)
        expect(renderer.personalization_data['location']).to eq location.data.stringify_keys
        expect(Donations::Utils).not_to have_received(:currency_from_country_code).with('DE')
      end

      it 'calls currency_from_country_code with member country' do
        member = build :member, country: 'DE'
        allow(location).to receive(:country_code) { 'GB' }
        allow(location).to receive(:data) { { country_code: 'GB' } }
        LiquidRenderer.new(page, member: member, location: location).personalization_data
        expect(Donations::Utils).to have_received(:currency_from_country_code).with('DE')
      end

      it 'calls currency_from_country_code with location country if member has none' do
        member = build :member, country: nil
        allow(location).to receive(:country_code) { 'GB' }
        allow(location).to receive(:data) { { country_code: 'GB' } }
        LiquidRenderer.new(page, member: member, location: location).personalization_data
        expect(Donations::Utils).to have_received(:currency_from_country_code).with('GB')
      end

      it 'sets location.country to member country if present' do
        member = build :member, country: 'DE'
        allow(location).to receive(:country_code) { 'GB' }
        allow(location).to receive(:data) { { country_code: 'GB' } }
        renderer = LiquidRenderer.new(page, member: member, location: location)
        expect(renderer.personalization_data['location']).to eq('country_code' => 'GB', 'currency' => 'USD', 'country' => 'DE')
      end

      it 'sets location.country to location.country_code if member has no country' do
        member = build :member, country: nil
        allow(location).to receive(:country_code) { 'GB' }
        allow(location).to receive(:data) { { country_code: 'GB' } }
        renderer = LiquidRenderer.new(page, member: member, location: location)
        expect(renderer.personalization_data['location']).to eq('country_code' => 'GB', 'currency' => 'USD', 'country' => 'GB')
      end
    end

    describe 'member' do
      it 'gives email as welcome name if no name' do
        member = build :member, first_name: nil, last_name: '', email: 'sup@dude.com'
        renderer = LiquidRenderer.new(page, member: member)
        expect(renderer.personalization_data['member']['welcome_name']).to eq 'sup@dude.com'
      end

      it 'gives first name and last name if available' do
        member = build :member, first_name: 'big', last_name: 'dog', email: 'sup@dude.com'
        renderer = LiquidRenderer.new(page, member: member)
        expect(renderer.personalization_data['member']['welcome_name']).to eq 'big dog'
      end
    end

    describe 'form_values' do
      let(:form1) { create :form_with_email_and_optional_country }
      let(:form2) { create :form_with_phone_and_country }
      let(:fundraiser) { create :plugins_fundraiser, page: page, form: form1 }
      let(:petition) { create :plugins_petition, page: page, form: form2 }
      let(:member) { build :member, first_name: 'Lemony', last_name: 'Snicket', email: 'sup@dude.com' }
      let(:url_params) { { controller: 'actions', country: 'NI', phone: '6697729' } }

      it 'has values from url_params and member_data filtered by keys from both forms' do
        fundraiser && petition # lazy eval
        renderer = LiquidRenderer.new(page, layout: nil, member: member, url_params: url_params)
        expected = { country: 'NI', email: 'sup@dude.com', phone: '6697729' }
        expect(renderer.personalization_data['form_values']).to eq(expected.stringify_keys)
      end

      it 'allows all the hidden field params' do
        fundraiser # lazy eval
        url_params.merge!(akid: 'a', bucket: 'b', source: 'c', referrer_id: 'd')
        renderer = LiquidRenderer.new(page, layout: nil, member: member, url_params: url_params)
        expected = { country: 'NI', email: 'sup@dude.com', akid: 'a', bucket: 'b', source: 'c', referrer_id: 'd' }
        expect(renderer.personalization_data['form_values']).to eq(expected.stringify_keys)
      end
    end

    describe 'thermometer' do
      it 'is nil if no plugins' do
        expect(page.plugins.size).to eq 0
        expect(LiquidRenderer.new(page).personalization_data['thermometer']).to eq nil
      end

      it 'is nil if no thermometer plugin' do
        create :plugins_fundraiser, page: page
        expect(page.plugins.size).to eq 1
        expect(LiquidRenderer.new(page).personalization_data['thermometer']).to eq nil
      end

      it "is serializes the thermometer plugin's data" do
        t1 = create :plugins_thermometer, page: page
        t1.current_progress # allow goal to update
        expected = t1.liquid_data.stringify_keys
        actual = LiquidRenderer.new(page).personalization_data['thermometer']
        # disagreement over timestamps is not what this test is about
        [expected, actual].each do |h|
          h.delete('updated_at')
          h.delete('created_at')
        end
        expect(actual).to eq expected
      end

      it 'is uses the first if multiple thermometer plugins' do
        t1 = create :plugins_thermometer, page: page, ref: 'secondary'
        create :plugins_thermometer, page: page
        expect(page.plugins.size).to eq 2
        t1.current_progress # allow goal to update
        expected = t1.liquid_data.stringify_keys
        actual = LiquidRenderer.new(page).personalization_data['thermometer']
        # disagreement over timestamps is not what this test is about
        [expected, actual].each do |h|
          h.delete('updated_at')
          h.delete('created_at')
        end
        expect(actual).to eq expected
      end
    end

    describe 'action_count' do
      it 'serializes page.action_count' do
        page.action_count = 1337
        expect(LiquidRenderer.new(page).personalization_data['action_count']).to eq 1337
      end
    end
  end

  describe LiquidRenderer::Cache do
    subject { LiquidRenderer::Cache.new('foo', 'bar') }
    let(:partial) { [double(:partial, cache_key: 'foobar')] }

    describe '.invalidate' do
      it 'increments invalidator seed' do
        expect(Rails.cache).to receive(:increment).with('cache_invalidator')
        LiquidRenderer::Cache.invalidate
      end
    end

    describe '#key_for_markup' do
      it 'follows pattern' do
        expect(subject.send(:key_for_markup)).to eq('liquid_markup:0:foo:bar')
      end
    end
  end
end
