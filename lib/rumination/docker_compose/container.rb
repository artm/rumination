require "dotenv/parser"
require_relative "sh"

module Rumination
  module DockerCompose
    Container = Struct.new(:name) do
      include Sh

      def has_file?(path)
        run "test -f #{path}"
        $? == 0
      end

      def up?
        exec "true"
        $? == 0
      end

      def exec command, *args
        sh "docker-compose exec", name, command, *args
        self
      end

      def run command, *args
        sh "docker-compose run --rm", name, command, *args
        self
      end

      def restart *args
        sh "docker-compose restart", name, *args
        self
      end

      def cp_to_container local_path, container_path, *args
        args << local_path
        args << "#{full_name}:#{container_path}"
        sh "docker cp", *args
      end

      def full_name
        "#{compose_project_name}_#{name}"
      end

      def compose_project_name
        env = if File.exists?(".env")
                Dotenv::Parser.call(File.read(".env"))
              else
                {}
              end
        env["COMPOSE_PROJECT_NAME"] || File.basename(Dir.pwd)
      end
    end
  end
end
