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

  private
  def find_first_name
    split_name = @full_name.split
    if split_name.length == 2
      @first_name = split_name[0]
    else
      @first_name = split_name.slice(0, (split_name.length / 2)).join(' ')
    end
  end

  def find_last_name
    split_name = @full_name.split
    if split_name.length == 2
      @last_name = split_name[1]
    else
      @last_name = split_name.slice((split_name.length/ 2), split_name.length).join(' ')
    end
  end
end
