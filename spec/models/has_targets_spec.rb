require 'rails_helper'

describe HasTargets do
  class Targetable
    include ActiveModel::Model
    include HasTargets
    set_target_class CallTool::Target

    # Work around ActiveRecord dependency
    def write_attribute(attr, value)
      instance_variable_set("@#{attr}", value)
    end

    def read_attribute(attr)
      instance_variable_get("@#{attr}")
    end
  end

  let(:targets) do
    [
      CallTool::Target.new(
        name: 'Richard Roth', title: 'Senator', phone_number: '19166514031',
        country_name: 'United States', country_code: 'US',
        fields: { state: 'California', 'other': nil }
      ),
      CallTool::Target.new(
        name: 'Tony Mendoza', title: 'Senator', phone_number: '19166514032',
        country_name: 'United States', country_code: 'US',
        fields: { state: 'California', 'other': nil }
      )
    ]
  end

  describe '#target_fields' do
    it 'returns keys for fields that are present in at least one of the targets' do
      keys = Targetable.new(targets: targets).target_fields
      expect(keys).to eq %i[name title phone_number country_name country_code state]
    end
  end

  describe '#target_filterable_fields' do
    it 'returns the keys for fields that are present except for the not filterable keys' do
      keys = Targetable.new(targets: targets).target_filterable_fields
      expect(keys).to eq %i[name title country_name state]
    end
  end
end
