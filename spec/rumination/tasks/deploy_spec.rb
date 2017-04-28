require "spec_helper"
require "rumination/deploy"
require "support/rake"

def stub_target &block
  expect(Rumination::Deploy).to receive(:load_target_config) do |target_name|
    Rumination::Deploy.configure do |config|
      block.call config
    end if block_given?
    Rumination::Deploy.target = target_name
  end
end

RSpec.describe "deploy" do
  include_context "rake"
  it "rebuilds containers; stops old services; starts new services" do
    stub_target
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose build", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose down --remove-orphans", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose up -d", any_args)
    expect { task.invoke }.to output.to_stdout
  end
end

RSpec.describe "deploy:bootstrap" do
  include_context "rake"
  it "rebuilds containers; stops old services; starts new services" do
    stub_target
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose build", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose down --remove-orphans", any_args)
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker-compose up -d", any_args)
    allow_any_instance_of(FileUtils).to receive(:sh)
    expect { task.invoke }.to output.to_stdout.and output.to_stderr_from_any_process
  end

  it "generates and uploads an app env file" do
    stub_target
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker cp tmp/development.env clientapp_app_1:/opt/app/env", any_args)
    allow_any_instance_of(FileUtils).to receive(:sh)
    expect { task.invoke }.to output.to_stdout.and output.to_stderr_from_any_process
  end

  it "copies files to container on request" do
    stub_target do |config|
      config.bootstrap = OpenStruct.new( copy_files: { "./foo" => "/opt/app/bar" })
    end
    expect_any_instance_of(FileUtils).to receive(:sh).with("docker cp ./foo clientapp_app_1:/opt/app/bar", any_args)
    allow_any_instance_of(FileUtils).to receive(:sh)
    expect { task.invoke }.to output.to_stdout.and output.to_stderr_from_any_process
  end
end

RSpec.describe "deploy:env" do
  include_context "rake"
  let(:preload_task_files) { %w[with_hash_puts] }
  it "outputs target name" do
    stub_target
    expect { task.invoke "production" }.to output(/# Loading 'production'/).to_stdout
  end

  it "configures VIRTUAL HOST" do
    stub_target do |config|
      config.virtual_host = "host.me"
    end
    expect { task.invoke }.to output(/^export VIRTUAL_HOST="host.me"/).to_stdout
  end

  it "configures COMPOSE_FILE" do
    stub_target do |config|
      config.compose_file = "compose.me"
    end
    expect { task.invoke }.to output(/^export COMPOSE_FILE="compose.me"/).to_stdout
  end

  it "raises UnknownTarget when that is the case" do
    expect do
      expect { task.invoke "unknown_target" }.to output(/# Loading 'unknown_target'/).to_stdout
    end.to raise_error Rumination::Deploy::UnknownTarget
  end
end
