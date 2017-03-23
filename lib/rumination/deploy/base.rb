require "dotenv/parser"
require "active_support/core_ext/module/delegation"
require_relative "../docker_compose"
require_relative "../generate"

module Rumination
  module Deploy
    Base ||= Struct.new(:target) do
      delegate :config, to: Deploy

      def bootstrap
        call do
          on_fresh_containers
        end
      end

      def call
        load_application_config_if_exists
        load_target_config
        DockerCompose.build.down("--remove-orphans").up
        yield if block_given?
        container(:backend)
          .exec("rake deploy:unload[#{target}]")
          .run("rake deploy:finish[#{target}]")
      end

      def on_fresh_containers
        puts "Bootstrapping '#{target}'"
        raise BootstrappedAlready if bootstrapped?
        write_env_file
        initialize_database
      end

      def load_application_config_if_exists
        load application_config_path if File.exists?(application_config_path)
      end

      def application_config_path
        "./config/deploy/application.rb"
      end

      def load_target_config
        ENV.merge env
      rescue LoadError => e
        raise UnknownTarget, e.message
      end

      def target_config_path
        "./config/deploy/targets/#{target}.rb"
      end

      def password_vars
        config.generate_passwords || Array(config.generate_password)
      end

      def env
        load target_config_path
        env = docker_machine_env
        env["VIRTUAL_HOST"] = config.virtual_host
        env["COMPOSE_FILE"] = config.compose_file if config.compose_file
        env
      end

      def docker_machine_env
        dm_env_str = `docker-machine env #{config.docker_machine}`
        Dotenv::Parser.call(dm_env_str)
      end

      def write_env_file
        password_vars.each do |var|
          container(:backend)
            .run(%Q[echo "#{var}=#{generate_password}" >> #{env_file_path}])
        end
      end

      def generate_password
        Generate.password
      end

      def bootstrapped?
        container(:backend).has_file?(env_file_path)
      end

      def initialize_database
        container(:backend).run("rake db:setup:maybe_load_dump")
        raise DatabaseInitError unless $? == 0
      end

      def env_file_path
        "/opt/app/env"
      end

      def container(name)
        DockerCompose::Container.new(name)
      end
    end
  end
end
