require "active_support/configurable"
require_relative "deploy/class_methods"

module Rumination
  module Deploy
    include ActiveSupport::Configurable
    extend Deploy::ClassMethods
    DeployError = Class.new(RuntimeError)
    UnknownTarget = Class.new(DeployError)
    BootstrapError = Class.new(DeployError)
    BootstrappedAlready = Class.new(BootstrapError)
    DatabaseInitError = Class.new(BootstrapError)
  end
end
