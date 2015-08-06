class LiquidLayout < ActiveRecord::Base

  has_many :campaign_pages

  validate :ordered_slots
  before_validation :count_slots

  def title_with_slots
    "#{title} - #{slot_count} slots"
  end

  private

  # needs a spec
  def slot_ids
    content.scan(/\{\{ *slot([0-9]+) *\}\}/).map(&:first).map(&:to_i)
  end

  def count_slots
    self.slot_count = slot_ids.size
  end

  # needs a spec
  def ordered_slots
    slots = self.slot_count
    if slot_ids.sort != (1..slots).to_a
      errors.add(:content, "There are #{slots} slot tags, but they do not match the numbers 1-#{slots}")
    end
  end

end
