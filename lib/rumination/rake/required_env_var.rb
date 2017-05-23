module Rake
  module RequiredEnvVar
    def required_env_var variable
      ENV[variable] or raise "supply #{variable} environment variable"
    end
  end
end
