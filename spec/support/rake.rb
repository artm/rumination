# rake tasks testing support
# based on the article by Joshua Clayton
# https://robots.thoughtbot.com/test-rake-tasks-like-a-boss
#
require "rake"
require "pathname"

RSpec.shared_context "rake" do
  let(:rake_load_path) { Pathname.new(File.expand_path("../../../lib/rumination/tasks", __FILE__)) }
  let(:rake) { Rake::Application.new }
  let(:task_name) { self.class.top_level_description }
  let(:task_path) { task_name.split(":").first }
  let(:preload_task_files) { [] }
  subject(:task) { rake[task_name] }

  def rake_require task_path
    already_loaded = $".reject {|file| file == "#{task_path}.rake" }
    Rake.application.rake_require(task_path, [rake_load_path], already_loaded)
  end

  around(:example) do |example|
    Rake.application = rake
    preload_task_files.each do |file|
      rake_require file
    end
    rake_require task_path
    Rumination.factory_reset
    Dir.chdir("spec/fixtures/client_app") do
      example.call
    end
  end
end
