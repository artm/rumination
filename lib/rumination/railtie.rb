require "rails/railtie"

module Rumination
  class Railtie < Rails::Railtie
    rake_tasks do
      require "rumination/deploy"
      Dir[File.expand_path("../tasks/**/*.rake", __FILE__)].each do |path|
        load path
      end
    end
  end
end
