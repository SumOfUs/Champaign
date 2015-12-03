module Donations
  module Utils
    extend self

    def round_and_dedup(values)
      deduplicate(round(values))
    end

    def round(values)
      values.map do |value|
        value = value.to_f

        if value < 20
          value.round(0)
        else
          (value.to_f / 5).round * 5
        end
      end
    end

    def deduplicate(values)
      duplicates = values.group_by{ |e| e }.select{ |k, v| v.size > 1 }.values.flatten

      safe = values - duplicates

      duplicates.each do |misfit|
        while safe.include? misfit
          misfit += (misfit < 20 ? 1: 5)
        end
        safe << misfit
      end
      safe.sort
    end
  end
end
