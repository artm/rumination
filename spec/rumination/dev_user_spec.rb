require "spec_helper"

describe Rumination::DevUser do
  subject(:default_user) { Rumination::DevUser.new }
  let(:user_with_email) { Rumination::DevUser.new(email: "overridden@email.com") }

  saved_env = nil

  before do
    saved_env = ENV.to_hash
    ENV["USER"] = "user"
    ENV["DEV_PASSWORD"] = "supersecret"
    ENV["DEV_HOST"] = "localhost.here"
  end

  after do
    ENV.update(saved_env)
  end

  it "uses $USER as name" do
    expect(default_user.name).to eq "user"
  end

  it "uses $DEV_PASSWORD as password" do
    expect(default_user.password).to eq "supersecret"
  end

  it "uses $DEV_HOST as host" do
    expect(default_user.host).to eq "localhost.here"
  end

  it "composes $USER and $DEV_HOST as email" do
    expect(default_user.email).to eq "user@localhost.here"
  end

  it "complains when can't init name" do
    ENV.delete "USER"
    expect { default_user }.to raise_error Rumination::DevUser::CannotBeInitialized
  end

  it "complains when can't init password" do
    ENV.delete "DEV_PASSWORD"
    expect { default_user }.to raise_error Rumination::DevUser::CannotBeInitialized
  end

  it "complains when can't init email" do
    ENV.delete "DEV_HOST"
    expect { default_user }.to raise_error Rumination::DevUser::CannotBeInitialized
  end

  it "doesn't complain if DEV_HOST is empty but email was supplied to constructor" do
    ENV.delete "DEV_HOST"
    expect { user_with_email }.to_not raise_error
    expect(user_with_email.email).to eq "overridden@email.com"
  end
end
