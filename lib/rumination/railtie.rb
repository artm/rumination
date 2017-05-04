require "rails/railtie"

module Rumination
  class Railtie < Rails::Railtie
    rake_tasks do
      require "rumination/tasks"
    end
    initializer "rumination.load_app_env" do
      require "dotenv"
      Dotenv.load("/opt/app/env") if File.exists?("/opt/app/env")
    end
  end
end
