module CampaignerFacingHelper
  def format_phone_number(number)
    number = number.to_s
    if Phony.plausible?(number)
      Phony.format(number)
    else
      number
    end
  end
end
