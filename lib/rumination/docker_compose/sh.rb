module Rumination
  module DockerCompose
    module Sh
      def sh command
        puts command
        system command
      end
    end
  end
end
