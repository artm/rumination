require "fileutils"
require "dotenv/parser"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
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

      def call
        setup_outside_env
        DockerCompose.build.down("--remove-orphans").up
        app_container.run("bundle install") if cached_gems?
        yield self if block_given?
        app_container.run("rake deploy:inside:unload[#{target}]")
        raise DeployError unless $? == 0
        app_container.run("rake deploy:inside:finish[#{target}]")
        raise DeployError unless $? == 0
      end

      def bootstrap
        raise BootstrappedAlready if bootstrapped?
        copy_dump_if_requested
        app_container.run("rake deploy:inside:write_env_file[#{target}]")
        app_container.run("rake deploy:inside:bootstrap[#{target}]")
        raise BootstrapError unless $? == 0
      end

      def bootstrap_undo
        setup_outside_env
        DockerCompose.down("--remove-orphans", "-v")
        raise BootstrapError unless $? == 0
      end

      def load_target_config
        load target_config_path
      rescue LoadError => e
        raise UnknownTarget, e.message
      end

      def setup_outside_env
        ENV.update env
      end

      def env
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
          persistent_env.merge(generated_passwords).each do |var, val|
            io.puts %Q[export #{var}="#{val}"]
          end
        end
      end

      def rm_env_file
        FileUtils.rm(env_file_path)
      end

      def persistent_env
        config.persistent_env || {}
      end

      def generated_passwords
        password_vars.map{|var| [var, generate_password]}.to_h
      end

      def generate_password
        Generate.password
      end

      private

      def copy_dump_if_requested
        source = config.copy_dumpfile
        return unless source.present?
        return unless File.exists?(source)
        target = Rumination.config.pg.dumpfile_path
        app_container.cp_to_container source, target
      end

      def load_application_config_if_exists
        load application_config_path if File.exists?(application_config_path)
      end

      def application_config_path
        "./config/deploy/application.rb"
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
        app_container.has_file?(env_file_path)
      end

      def env_file_path
        "/opt/app/env"
      end

      def container(name)
        DockerCompose::Container.new(name)
      end

      def app_container_name
        config.app_countainer || :app
      end

      def app_container
        container(app_container_name)
      end

      def cached_gems?
        target.to_sym == :development
      end
    end
  end
end
