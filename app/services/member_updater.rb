# frozen_string_literal: true

class MemberUpdater
  def self.run(member, params)
    new(member, params).run
  end

  def initialize(member, params)
    @member = member
    @params = params.try(:to_unsafe_hash) || params.to_h
    @params = @params.symbolize_keys.compact
  end

  def run
    @member.name = @params[:name] if @params.key? :name
    @member.donor_status = @params[:donor_status] if @params[:donor_status] && !@member.recurring_donor?
    @member.assign_attributes(
      @params.slice(
        :email, :country, :first_name, :last_name, :city, :postal, :title, :address1, :address2, :consented
      )
    )
    @member.more = (@member.more || {}).merge(@params.select { |attr| belongs_in_more? attr })
    @member.save!
  end

  private

  def member_attributes
    @member_attributes ||= Member.column_names.map(&:to_sym).reject { |attr| %i[id actionkit_user_id].include? attr }
  end

  def belongs_in_more?(attr)
    !member_attributes.include?(attr) && ActionKitFields.has_valid_form(attr)
  end
end
