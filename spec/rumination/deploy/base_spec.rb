require "rumination/deploy"

RSpec.describe Rumination::Deploy::Base do
  subject(:deploy) { Rumination::Deploy::Base.new(:development) }
  before do
    allow(deploy).to receive(:target_config_path) {
      "spec/fixtures/deploy_target_config.rb"
    }
  end

  it "remembers its target" do
    expect(deploy.target).to eq(:development)
  end

  it "generates passwords" do
    expect(deploy.generate_password).to be_a String
  end
end
