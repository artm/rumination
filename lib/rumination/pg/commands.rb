require_relative "restore"

module Rumination
  module Pg
    configure do |config|
      config.create_dump_args = %w[--compress=9]
      config.load_dump_args = %w[--quiet]
    end

    # include this module into something with #sh, e.g. next to Rake::FileUtils
    module Commands
      def pg_restore *args
        Pg::Restore.call *args, "-d", ENV["PGDATABASE"]
      end

      def rsync *args
        sh "rsync #{args.join(" ")}"
      end

      def create_dump path, *args
        args = Pg.config.create_dump_args + args + %W[--file=#{path}]
        sh "pg_dump #{args.join(" ")}"
      end

      def load_dump path, *args
        args = Pg.config.load_dump_args + args
        sh "gunzip -c #{path} | psql #{args.join(" ")}"
      end
    end
  end
end
