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

  context "with target config" do
    let(:docker_machine_env) {
      {
        "DOCKER_TLS_VERIFY" => "1",
        "DOCKER_HOST" => "tcp://37.97.229.105:2376",
        "DOCKER_CERT_PATH" => "/home/artm/.docker/machine/machines/mancave",
        "DOCKER_MACHINE_NAME" => "mancave"
      }
    }
    before do
      allow(deploy).to receive(:docker_machine_env) { docker_machine_env }
      Rumination::Deploy.configure do |config|
        config.virtual_host = "host.me"
        config.compose_file = "docker-compose.some.yml"
      end
    end
    it "produced a hash of env variables" do
      expect(deploy.env).to match docker_machine_env.merge(
        "COMPOSE_FILE" => "docker-compose.some.yml",
        "VIRTUAL_HOST" => "host.me"
      )
    end
  end
end
