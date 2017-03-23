$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rumination"

RSpec.configure do |config|
  config.order = :random
  config.disable_monkey_patching!
end
