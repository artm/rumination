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
    end
  end
end
