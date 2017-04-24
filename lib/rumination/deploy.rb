require "active_support/configurable"
require_relative "deploy/class_methods"
require "dotenv/parser"

module Rumination
  module Deploy
    include ActiveSupport::Configurable
    extend Deploy::ClassMethods
    DeployError = Class.new(RuntimeError)
    UnknownTarget = Class.new(DeployError)
    BootstrapError = Class.new(DeployError)
    BootstrappedAlready = Class.new(BootstrapError)
    DatabaseInitError = Class.new(BootstrapError)

    def docker_env
      env = {}
      if config.docker_machine
        dm_env_str = `docker-machine env #{config.docker_machine}`
        env = env.merge(Dotenv::Parser.call(dm_env_str))
      end
      env["COMPOSE_FILE"] = config.compose_file if config.compose_file
      env["VIRTUAL_HOST"] = config.virtual_host
      if config.letsencrypt_email.present?
        env["LETSENCRYPT_HOST"] = config.virtual_host
        env["LETSENCRYPT_EMAIL"] = config.letsencrypt_email
      end
      env
    end
  end
end
