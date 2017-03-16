module Rumination
  module Pg
    class Restore
      attr_reader :args

      def initialize *args
        require "open3"
        @args = args.dup.freeze
      end

      def self.call *args
        new(*args).call
      end

      def call
        command = "pg_restore #{args.join(" ")}"
        puts command
        Open3.popen3 ENV, command do |stdin, stdout, stderr, thread|
          out_lines = stdout.readlines
          err_lines = stderr.readlines
          save_stream :stdout, out_lines
          save_stream :stderr, err_lines
          puts_log out_lines + err_lines, indent: 2
          analyse_stderr! err_lines
        end
      end

      private

      def puts_log lines, indent: 0
        lines = lines.dup
        lines[3..-4] = ["", "... snip snip ...", ""] unless lines.count < 8
        lines.each do |line|
          puts line.indent(indent)
        end
      end

      def analyse_stderr! lines
        text = lines.join("\n")
        error_count = text.scan(/ERROR/).count
        more_errors_than_ignored = error_count > 0 && !expected_errors?(text, error_count)
        other_errors = error_matchers.any?{|m| m === text}
        if more_errors_than_ignored || other_errors
          raise RuntimeError, "pg_restore seems to have failed"
        end
      end

      def save_stream name, lines
        File.open("log/pg_restore.#{name}.log","w") do |io|
          io.puts lines
        end
      end

      def save_streams out_lines, err_lines
      end

      def error_matchers
        [
          /could not open input file/
        ]
      end

      def expected_errors? text, count
        text =~ /WARNING: errors ignored on restore: #{count}/
      end
    end
  end
end
