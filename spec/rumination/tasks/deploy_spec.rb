require "support/rake"

RSpec.describe "deploy:env" do
  include_context "rake"
  it "runs" do
    task.invoke
  end
end
