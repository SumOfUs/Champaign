# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string
#  actionkit_uri :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

describe Tag do
  let(:tag) { create :tag }
  let(:english) { create :language }
  let(:tag_params) { attributes_for :tag }

  subject { tag }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :actionkit_uri }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :pages_tags }
  it { is_expected.to respond_to :pages }

  describe 'pages' do
    before do
      3.times { create :page, language: english }
    end

    describe '.destroy' do
      let!(:tag) { create :tag, page_ids: Page.last(2).map(&:id) }

      it 'does not destroy page' do
        expect { tag.destroy }.to change { Page.count }.by 0
      end

      it 'destroys table joins' do
        expect { tag.destroy }.to change { PagesTag.count }.by -2
      end

      it 'destroys tag' do
        expect { tag.destroy }.to change { Tag.count }.by -1
      end
    end
  end

  describe 'scopes' do
    let!(:issue_tag) { create(:tag, name: '#AnimalRights') }
    let!(:region_tag) { create(:tag, name: '@Global') }

    describe 'issue tag' do
      it 'returns issue tags' do
        expect(Tag.issue).to eq([issue_tag])
      end
    end

    describe 'region tag' do
      it 'returns region tags' do
        expect(Tag.region).to eq([region_tag])
      end
    end
  end
end
