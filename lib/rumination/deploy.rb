require "active_support/configurable"
require_relative "deploy/class_methods"

module Rumination
  module Deploy
    include ActiveSupport::Configurable
    extend Deploy::ClassMethods
    UnknownTarget = Class.new(RuntimeError)
    BootstrappedAlready = Class.new(RuntimeError)
    DatabaseInitError = Class.new(RuntimeError)
  end
end
