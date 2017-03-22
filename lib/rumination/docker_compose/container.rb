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

      def exec command
        sh "docker-compose exec #{name} #{command}"
        self
      end

      def run command
        sh "docker-compose run --rm #{name} #{command}"
        self
      end

      def restart
        sh "docker-compose restart #{name}"
        self
      end
    end
  end
end
