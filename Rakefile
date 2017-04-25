require "rspec/core/rake_task"
require "highline/import"
require "active_support/core_ext/object/blank"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :release do
  puts "oi!"
  current_version = Rumination::VERSION
  released = `git tag -l v#{current_version}`.present?
  if released
    major, minor, build = current_version.split(".")
    major, minor, build = [major, minor, build].map(&:to_i)
    next_build = [major, minor, build+1].join(".")
    next_minor = [major, minor + 1].join(".")
    next_major = [major + 1, 0].join(".")
    next_version = nil
    choose do |menu|
      menu.prompt = "Choose new version"
      menu.choice(next_build) { next_version = next_build }
      menu.choice(next_minor) { next_version = next_minor }
      menu.choice(next_major) { next_version = next_major }
      menu.default = next_build
    end
    version_src = "lib/rumination/version.rb"
    version_tmp = "tmp/next_version.rb"
    mkdir_p "tmp"
    sh %Q[cat #{version_src} | sed s:#{current_version}:#{next_version}: > #{version_tmp}]
    cp version_tmp, version_src
    sh %Q[git add #{version_src}]
    sh %Q[git commit -m "version bump to #{next_version}"]
    Rumination.send(:remove_const, "VERSION")
    load version_src
    puts "version is now: #{Rumination::VERSION}"
  end
end

require "bundler/gem_tasks"
