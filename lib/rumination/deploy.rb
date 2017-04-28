require "active_support/configurable"
require "active_support/core_ext/module"
require_relative "deploy/class_methods"
require "dotenv/parser"

module Rumination
  module Deploy
    mattr_accessor :target
    include ActiveSupport::Configurable
    extend Deploy::ClassMethods
    DeployError = Class.new(RuntimeError)
    UnknownTarget = Class.new(DeployError)
    BootstrapError = Class.new(DeployError)
    BootstrappedAlready = Class.new(BootstrapError)
    DatabaseInitError = Class.new(BootstrapError)
    factory_reset!
  end
end
