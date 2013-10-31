module HattrAccessor
  def hattr_reader(source, *keys)
    ensure_readable source
    keys.each do |key|
      define_method(key) { send(source).fetch(key) }
    end
  end
  alias_method :hattr_readers, :hattr_reader

  def hattr_writer(source, *keys)
    ensure_readable source
    keys.each do |key|
      define_method("#{key}=") do |value|
        send("#{source}").store(key, value)
      end
    end
  end
  alias_method :hattr_writers, :hattr_writer

  def hattr_accessor(source, *keys)
    hattr_reader source, *keys
    hattr_writer source, *keys
  end
  alias_method :hattr_accessors, :hattr_accessor


  protected

  def ensure_readable(source)
    attr_reader(source) unless method_defined?(source)
  end
end
