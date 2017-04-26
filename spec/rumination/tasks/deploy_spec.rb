require "spec_helper"
require "rumination/deploy"
require "support/rake"

RSpec.describe "deploy" do
  include_context "rake"
  it "rebuilds containers; stops old services; starts new services" do
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose build", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose down --remove-orphans", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose up -d", any_args)
    expect { task.invoke }.to output.to_stdout
  end
end

RSpec.describe "deploy:bootstrap" do
  include_context "rake"
  it "can be invoked" do
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose build", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose down --remove-orphans", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose up -d", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker cp tmp/development.env clientapp_app_1:/opt/app/env", any_args)
    task.invoke
  end
end

RSpec.describe "deploy:env" do
  include_context "rake"
  let(:preload_task_files) { %w[with_hash_puts] }

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
