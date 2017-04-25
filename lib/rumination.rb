require "active_support/configurable"
require "rumination/railtie" if defined?(Rails)

module Rumination
  include ActiveSupport::Configurable
end

require_relative "rumination/version"
require_relative "rumination/dev_user"
require_relative "rumination/pg"

module Rumination
  def self.factory_reset
    config.clear
    configure do |config|
      config.pg = Rumination::Pg.config
    end
  end

  factory_reset
end
