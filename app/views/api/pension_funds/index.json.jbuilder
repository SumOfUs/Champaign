json.array! @pension_funds do |fund|
  json._id fund.uuid
  json.name fund.name
  json.fund fund.fund
  json.email fund.email
end
