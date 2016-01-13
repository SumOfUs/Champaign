require 'rails_helper'

describe Member do
  let(:first_name) { 'Emilio' }
  let(:last_name) { 'Estevez' }
  let(:full_name) { "#{first_name} #{last_name}" }
  let(:unicode_first) { 'Éöíñ'}
  let(:unicode_last) { 'Ńūñèž' }
  let(:unicode_full) { "#{unicode_first} #{unicode_last}" }
  let(:chinese_first) { '台'}
  let(:chinese_last) { '北' }
  let(:chinese_full) { "#{chinese_first} #{chinese_last}"}

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

  it 'correctly handles unicode characters' do
    member = Member.new
    member.name = unicode_full
    expect(member.first_name).to eq(unicode_first)
    expect(member.last_name).to eq(unicode_last)
    expect(member.name).to eq(unicode_full)
  end

  it 'correctly handles high-value unicode characters' do
    member = Member.new
    member.name = chinese_full
    expect(member.first_name).to eq(chinese_first)
    expect(member.last_name).to eq(chinese_last)
    expect(member.name).to eq(chinese_full)
  end
end
