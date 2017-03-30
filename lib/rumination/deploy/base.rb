require "dotenv/parser"
require "active_support/core_ext/module/delegation"
require_relative "../docker_compose"
require_relative "../generate"

module Rumination
  module Deploy
    Base ||= Struct.new(:target) do
      delegate :config, to: Deploy

      def initialize *args
        super
        load_application_config_if_exists
        load_target_config
      end

      def bootstrap
        call do
          on_fresh_containers
        end
      end

      def call
        DockerCompose.build.down("--remove-orphans").up
        yield if block_given?
        container(:backend).exec("rake deploy:unload[#{target}]")
        raise DeployError unless $? == 0
        container(:backend).run("rake deploy:finish[#{target}]")
        raise DeployError unless $? == 0
      end

      def env
        load target_config_path
        env = docker_machine_env
        env["VIRTUAL_HOST"] = config.virtual_host
        if config.letsencrypt_email.present?
          env["LETSENCRYPT_HOST"] = config.virtual_host
          env["LETSENCRYPT_EMAIL"] = config.letsencrypt_email
        end
        env["COMPOSE_FILE"] = config.compose_file if config.compose_file
        env
      end

      def write_env_file
        File.open(env_file_path, "w") do |io|
          password_vars.each do |var|
            puts "Generating #{var}"
            io.puts %Q[export #{var}="#{generate_password}"]
          end
        end
      end

      def generate_password
        Generate.password
      end

      private

      def on_fresh_containers
        raise BootstrappedAlready if bootstrapped?
        container(:backend).run("rake deploy:bootstrap:inside[#{target}]")
        raise BootstrapError unless $? == 0
      end

      def load_application_config_if_exists
        load application_config_path if File.exists?(application_config_path)
      end

      def application_config_path
        "./config/deploy/application.rb"
      end

      def load_target_config
        ENV.update env
      rescue LoadError => e
        raise UnknownTarget, e.message
      end

      def target_config_path
        (config.target_config_path || "./config/deploy/targets/%s.rb") % target
      end

      def password_vars
        config.generate_passwords || Array(config.generate_password)
      end

      def docker_machine_env
        dm_env_str = if config.docker_machine
                       `docker-machine env #{config.docker_machine}`
                     else
                       ""
                     end
        Dotenv::Parser.call(dm_env_str)
      end

      def bootstrapped?
        container(:backend).has_file?(env_file_path)
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
