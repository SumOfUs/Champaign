class MemberUpdater
  def self.run(member, params)
    new(member, params).run
  end

  def initialize(member, params)
    @member, @params = member, params
  end

  def run
    @member.name = @params[:name] if @params.key? :name
    @member.actionkit_user_id = action_kit_user_id if action_kit_user_id.present?
    @member.assign_attributes(filtered_params)
    @member.save!
  end

  private

  def action_kit_user_id
    AkidParser.parse(@params[:akid], Settings.action_kit.akid_secret)[:actionkit_user_id]
  end

  def filtered_params
    hash = @params.try(:to_unsafe_hash) || @params.to_h # for ActionController::Params
    hash.symbolize_keys.compact.keep_if { |k| permitted_keys.include? k }
  end

  def permitted_keys
    Member.new.attributes.keys.map(&:to_sym).reject! { |k| k == :id }
  end
end
