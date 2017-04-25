# rake tasks testing support
# based on the article by Joshua Clayton
# https://robots.thoughtbot.com/test-rake-tasks-like-a-boss
#
require "rake"

RSpec.shared_context "rake" do
  let(:rake) { Rake::Application.new }
  let(:task_name) { self.class.top_level_description }
  let(:task_path) { "lib/rumination/tasks/#{task_name.split(":").first}" }
  subject(:task) { rake[task_name] }

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == "#{task_path}.rake" }
  end

  around(:example) do |example|
    Rake.application = rake
    Rake.application.rake_require(task_path, ["."], loaded_files_excluding_current_rake_file)
    Rumination.factory_reset
    Dir.chdir("spec/fixtures/client_app") do
      example.call
    end
  end
end
