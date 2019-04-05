# frozen_string_literal: true

json.hours        total_actions_by_hour(@page)
json.days_total   total_actions_by_day(@page)
json.days_new     new_members_by_day(@page)

json.totals do
  json.all_total @page.total_actions
end
