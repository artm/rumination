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
    end
  end
end
