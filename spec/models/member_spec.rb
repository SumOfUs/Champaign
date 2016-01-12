require 'rails_helper'

describe Member do
  let(:first_name) { 'Emilio' }
  let(:last_name) { 'Estevez' }
  let(:full_name) { "#{first_name} #{last_name}" }

  it 'correctly joins first and last name' do
    member = Member.new
    member.first_name = first_name
    member.last_name = last_name
    expect(member.name).to eq(full_name)
  end

  it 'correctly splits full_name into first and last name' do
    member = Member.new
    member.name = full_name
    expect(member.first_name).to eq(first_name)
    expect(member.last_name).to eq(last_name)
    expect(member.name).to eq(full_name)
  end
end
