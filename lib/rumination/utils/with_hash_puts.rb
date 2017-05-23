module Kernel
  alias_method :orig_puts, :puts
  def hash_puts *args
    print "# "
    orig_puts *args
  end

  def with_hash_puts
    Kernel.send :alias_method, :puts, :hash_puts
    yield
  ensure
    Kernel.send :alias_method, :puts, :orig_puts
  end
end
