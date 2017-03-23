require "rails/railtie"

module Rumination
  class Railtie < Rails::Railtie
    rake_tasks do
      require "rumination/deploy"
      Dir[File.expand_path("../tasks/**/*.rake", __FILE__)].each do |path|
        load path
      end
    end
    initializer "rumination.load_app_env" do
      require "dotenv"
      Dotenv.load("/opt/app/env") if File.exists?("/opt/app/env")
    end
  end
end
