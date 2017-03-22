require_relative "docker_compose/container"
require_relative "docker_compose/sh"

module Rumination
  module DockerCompose
    extend Sh

    def self.build
      sh "docker-compose build"
      self
    end

    def self.down
      sh "docker-compose down"
      self
    end

    def self.up
      sh "docker-compose up -d"
      self
    end
  end
end
