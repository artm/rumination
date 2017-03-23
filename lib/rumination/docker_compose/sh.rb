module Rumination
  module DockerCompose
    module Sh
      def sh command, *more_args
        command = [command, *more_args].join(" ")
        puts command
        system command
      end
    end
  end
end
