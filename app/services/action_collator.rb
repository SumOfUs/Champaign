# frozen_string_literal: true
class ActionCollator
  PRIVATE_KEYS = %w(action_referrer_email action_referer action_express_donation).freeze
  PREFIXES = %w(action_ textentry_ box_ dropdown_ choice_).freeze
  COLUMN_KEYS = %w(publish_status id).freeze
  COMMA = ','

  def self.run(actions)
    new(actions).run
  end

  def self.csv(actions, keys: nil, skip_headers: false)
    new(actions, keys: keys, skip_headers: skip_headers).csv
  end

  def initialize(actions, keys: nil, skip_headers: false)
    @actions = actions
    @keys = keys
    @skip_headers = skip_headers
  end

  def run
    [hashes, headers]
  end

  def csv
    rows = @actions.map do |action|
      keys.map do |k|
        value = val(k, action)
        (value.is_a?(String) && value.index(COMMA).present?) ? "\"#{value}\"" : value
      end
    end
    rows = rows.unshift(keys.map { |k| headers[k] }) unless @skip_headers
    rows.map { |r| r.join(',') }.join("\n")
  end

  def hashes
    @hashes ||= @actions.map do |action|
      keys.map { |k| [k, val(k, action)] }.to_h.symbolize_keys
    end
  end

  def keys
    return @keys if @keys.present?
    all_keys = @actions.map { |a| a.form_data.keys }.flatten.uniq
    @keys = all_keys.reject { |k| PRIVATE_KEYS.include?(k) }.select { |k| ActionKitFields.has_valid_form(k) }
    @keys = (@keys + COLUMN_KEYS).map(&:to_sym)
  end

  def headers
    @headers ||= keys.map do |key|
      short = key.to_s
      PREFIXES.each { |p| short = short.remove(p) }
      [key, short.titleize]
    end.to_h.symbolize_keys
  end

  private

  def val(key, action)
    val = action.try(key.to_sym)
    val.blank? ? action.form_data[key.to_s] : val
  end
end
