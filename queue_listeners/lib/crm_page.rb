class CrmPage
  attr_accessor :language, :resource_uri, :type,
                :name, :id, :status, :hidden, :title, :base_url

  def initialize(provided_id=nil, base_url=nil)
    @id = provided_id
    # I'm not sure yet that the base_url is actually important, but
    # we're storing it here for the time being.
    @base_url = base_url
  end

  def action_count
    if @id

    else
      raise StandardError 'Page has not been saved to ActionKit, save it before trying to access actions.'
    end
  end

  def ==(other_obj)
    # We don't care about object IDs in determining if pages are the same thing,
    # so we override the initial `==` method to just check whether or not
    # the attributes are all the same
    attributes = self.instance_values
    other_attributes = other_obj.instance_values
    attributes.each do |k, _|
      if attributes[k] == other_attributes[k]
        next
      else
        return false
      end
    end
    true
  end
end
