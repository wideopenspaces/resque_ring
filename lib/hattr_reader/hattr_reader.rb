module HattrReader
  def hattr_reader(source, *keys)
    attr_reader source # ensure we have a reader for the source
    keys.each do |key|
      define_method(key) { send(source)[key] }
    end
  end
end
