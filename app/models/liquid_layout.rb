class LiquidLayout < ActiveRecord::Base

  has_many :campaign_pages

  validates :content, presence: true, allow_blank: false
  validates :title, presence: true, allow_blank: false

  validate :ordered_slots
  before_validation :count_slots

  def title_with_slots
    "#{title} - #{slot_count} slots"
  end

  def slot_regex
    # see the spec to better understand what this matches
    /\{\{ *slot *([0-9]+) *\}\}\s*(<!-- *(.*?) *-->){,1}/
  end

  def slot_ids
    return [] unless content.present?
    return content.scan(slot_regex).map{ |captured| captured.first.to_i }
  end

  def slot_labels
    return [] unless content.present?
    return content.scan(slot_regex).map{ |captured| captured[2] || "" }
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
