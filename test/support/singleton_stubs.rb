# frozen_string_literal: true

# Minimal replacement for minitest/mock's `stub`, which is not bundled with minitest 6.
# Temporarily redefines a singleton method on `object` with `replacement` for the duration of the block.
module SingletonStubs
  def stub_singleton(object, method_name, replacement)
    object.define_singleton_method(method_name, &replacement)
    yield
  ensure
    object.singleton_class.remove_method(method_name)
  end
end
