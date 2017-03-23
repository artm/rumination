require "securerandom"

module Rumination
  module Generate
    def self.password
      SecureRandom.base64(12)
    end
  end
end
