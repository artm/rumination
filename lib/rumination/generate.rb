require "securerandom"

module Rumination
  module Generate
    def self.password
      SecureRandom.base64(12)
    end

    def self.secret_key_base
      SecureRandom.hex(64)
    end
  end
end
