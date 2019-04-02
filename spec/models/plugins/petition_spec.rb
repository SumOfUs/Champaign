# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_petitions
#
#  id          :integer          not null, primary key
#  active      :boolean          default(FALSE)
#  cta         :string
#  description :text
#  ref         :string
#  target      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  form_id     :integer
#  page_id     :integer
#
# Indexes
#
#  index_plugins_petitions_on_form_id  (form_id)
#  index_plugins_petitions_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (form_id => forms.id)
#  fk_rails_...  (page_id => pages.id)
#

require 'rails_helper'
require_relative 'shared_examples'

describe Plugins::Petition do
  subject(:petition) { create(:plugins_petition) }

  include_examples 'plugin with form', :plugins_petition

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :description }
  it { is_expected.to respond_to :target }
  it { is_expected.to respond_to :cta }
  it { is_expected.to respond_to :page_id }
  it { is_expected.to respond_to :active }
  it { is_expected.to respond_to :ref }

  it 'is invalid without cta' do
    petition.cta = ''
    expect(petition).to be_invalid
  end

  it 'is valid without target' do
    petition.target = ''
    expect(petition).to be_valid
  end
end
