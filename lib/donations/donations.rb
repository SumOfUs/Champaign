module Donations
  def self.round(value)
    if value < 20
      value.round(0)
    else
      (value.to_f / 5).round * 5
    end
  end
end
