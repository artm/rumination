require "support/rake"

RSpec.describe "deploy:env" do
  include_context "rake"
  it "outputs target name" do
    expect { task.invoke }.to output(/# Loading 'development'/).to_stdout
  end

  it "outputs variable exports" do
    expect(Rumination::Deploy).to receive(:docker_env) { { "DOCKER_VARIABLE" => "value" } }
    expect { task.invoke }.to output(/^export DOCKER_VARIABLE="value"/).to_stdout
  end

  it "configures VIRTUAL HOST" do
    expect { task.invoke "host_compose" }.to output(/^export VIRTUAL_HOST="host.me"/).to_stdout
  end

  it "configures COMPOSE_FILE" do
    expect { task.invoke "host_compose" }.to output(/^export COMPOSE_FILE="compose.me"/).to_stdout
  end

  it "raises UnknownTarget when that is the case" do
    expect do
      expect { task.invoke "unknown_target" }.to output(/# Loading 'unknown_target'/).to_stdout
    end.to raise_error Rumination::Deploy::UnknownTarget
  end
end
