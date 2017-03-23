require_relative "docker_compose/container"
require_relative "docker_compose/sh"

module Rumination
  module DockerCompose
    extend Sh

    def self.build *args
      sh "docker-compose build", *args
      self
    end

    def self.down *args
      sh "docker-compose down", *args
      self
    end

    def self.up *args
      sh "docker-compose up -d", *args
      self
    end
  end
end
