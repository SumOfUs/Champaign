# frozen_string_literal: true
class ActionReader
  attr_reader :query

  DEFAULT_PER_PAGE = 30

  def initialize(query)
    @query = query
  end

  def run(page_number: 1, per_page: DEFAULT_PER_PAGE)
    action_pagination = Action.where(query).page(page_number).per(per_page)
    ActionCollator.run(action_pagination).push(action_pagination)
  end

  def csv(page_number: nil, per_page: DEFAULT_PER_PAGE)
    arq = Action.where(query)

    if page_number.present? # don't bother with batches if we're paginating
      ActionCollator.csv(arq.page(page_number).per(per_page))
    else
      output = []
      all_keys = keys(arq)
      arq.find_in_batches do |group|
        is_first = output.empty?
        output.push(ActionCollator.csv(group, keys: all_keys, skip_headers: !is_first))
      end
      output.join("\n")
    end
  end

  def keys(arq)
    keys_set = Set.new
    arq.find_in_batches do |group|
      keys_set.merge(ActionCollator.new(group).keys)
    end
    keys_set.to_a
  end
end
