require_relative "../docker_compose"
require "dotenv/parser"

module Rumination
  module Deploy
    Base ||= Struct.new(:target) do
      def bootstrap
        call do
          on_fresh_containers
        end
      end

      def call
        load_target_config
        DockerCompose.build.down.up
        yield if block_given?
        container(:backend)
          .exec("rake deploy:unload[#{target}]")
          .run("rake deploy:finish[#{target}]")
      end

      def on_fresh_containers
        puts "Bootstrapping '#{target}'"
        raise BootstrappedAlready if bootstrapped?
        initialize_database
      end

      def load_target_config
        load "./config/deploy/targets/#{target}.rb"
        ENV["VIRTUAL_HOST"] = Deploy.config.virtual_host
        ENV["COMPOSE_FILE"] = Deploy.config.compose_file if Deploy.config.compose_file
        setup_docker_machine_env if Deploy.config.docker_machine
      rescue LoadError => e
        raise UnknownTarget, e.message
      end

      def setup_docker_machine_env
        dm_env_str = `docker-machine env #{Deploy.config.docker_machine}`
        ENV.update Dotenv::Parser.call(dm_env_str)
      end

      def bootstrapped?
        false
      end

      def initialize_database
        container(:backend).run("rake db:setup:maybe_load_dump")
        raise DatabaseInitError unless $? == 0
      end

      def container(name)
        DockerCompose::Container.new(name)
      end
    end
  end
end
