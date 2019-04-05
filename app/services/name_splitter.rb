# frozen_string_literal: true

class NameSplitter
  def initialize(full_name:)
    @full_name = full_name
  end

  def first_name
    @first_name || find_first_name
  end

  def last_name
    @last_name || find_last_name
  end

  def split_name
    @split_name = @full_name.split
  end

  private

  def find_first_name
    @first_name =
      if @full_name.blank?
        ''
      elsif split_name.length == 1
        @full_name
      elsif split_name.length == 2
        split_name[0]
      else
        split_name.slice(0, (split_name.length / 2)).join(' ') # integer division, so will always round to lower whole
      end
  end

  def find_last_name
    @last_name =
      if @full_name.blank? || split_name.length == 1
        ''
      elsif split_name.length == 2
        split_name[1]
      else
        split_name.slice((split_name.length / 2), split_name.length).join(' ') # integer division, so will always round to lower whole
      end
  end
end
