class CrmPage
  attr_accessor :language, :resource_uri, :type,
                :name, :crm_id, :status, :hidden, :title, :base_url,
                :active

  def initialize(value_hash={})
    update_values(value_hash)
  end

  # A simple method for assigning any provided values, as a way to be DRY
  # since we've got a lot of places that values need to be set.
  def update_values(values={})
    values.each do |key, value|
      if self.respond_to? key
      # instance_variable_set requires the '@' symbol prepended to the name of the variable
        self.instance_variable_set("@#{key}", value)
      end
    end
  end

  def status
    active? ? 'active' : 'inactive'
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
