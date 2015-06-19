def image_name_valid(contents)
  if contents.has_key? :image_url
    (image_is_external_url(contents[:image_url]) or image_has_uuid(contents[:image_url]))
  else
    true
  end
end

def image_is_external_url(string_to_check)
  # Checks whether the file name points to an external URL like http://imgur.com
  if (string_to_check =~ /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/).nil?
    false
  else
    true
  end
end

def image_has_uuid(string_to_check)
  # Checks whether the image name has a UUID in it, of the form:
  # 6987f1d1-bf76-4985-94e9-08a354f4712f
  if (string_to_check =~ /[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/).nil?
    false
  else
    true
  end
end

def add_uuid_to_filename(string_to_modify)
  # split on the file name separator
  split_string = string_to_modify.split '.'
  if split_string.length == 1
    # There's only one thing here, so stick the UUID on the end.
    split_string[0] + SecureRandom.uuid.to_s
  elsif split_string.length == 2
    # file name and extension, so stick the UUID on the end of the file name and recombine
    split_string[0] = split_string[0] + SecureRandom.uuid.to_s
    split_string.join '.'
  else
    # multiple periods, so stick the UUID on the item just before the extension and recombine
    split_string[-2] = split_string[-2] + SecureRandom.uuid.to_s
    split_string.join '.'
  end
end
