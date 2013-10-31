require 'yaml'

class Yambol
  def self.load_file(file)
    symbolize_keys(::YAML.load_file(file))
  end

  # owes a debt to http://devblog.avdi.org/2009/07/14/recursively-symbolize-keys/
  def self.symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      result[converted_key(key)] = converted_value(value)
      result
    }
  end

  def self.converted_key(key)
    key.is_a?(String) ? key.to_sym : key
  end

  def self.converted_value(value)
    value.is_a?(Hash) ? symbolize_keys(value) : value
  end
end