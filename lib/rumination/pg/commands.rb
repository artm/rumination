require_relative "restore"

module Rumination
  module Pg
    # include this module into something with #sh, e.g. next to Rake::FileUtils
    module Commands
      def pg_dump *args
        sh "pg_dump #{args.join(" ")}"
      end

      def pg_restore *args
        Pg::Restore.call *args, "-d", ENV["PGDATABASE"]
      end

      def rsync *args
        sh "rsync #{args.join(" ")}"
      end

      def create_dump path, *args
        args = [
          *required_create_dump_args,
          *configured_create_dump_args,
          "--file=#{path}",
          *args]
        sh "pg_dump #{args.join(" ")}"
      end

      def required_create_dump_args
        []
      end

      def configured_create_dump_args
        %w[--compress=9]
      end
    end
  end
end
