require "active_support/configurable"
require "rumination/railtie" if defined?(Rails)

module Rumination
  include ActiveSupport::Configurable
end

require_relative "rumination/version"
require_relative "rumination/dev_user"
require_relative "rumination/pg"

Rumination.configure do |config|
  config.pg = Rumination::Pg.config
end
