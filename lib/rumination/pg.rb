require "active_support/configurable"

module Rumination
  module Pg
    include ActiveSupport::Configurable
  end
end

require_relative "pg/commands"
