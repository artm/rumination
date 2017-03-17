require "spec_helper"

class TestDsl
  include Rumination::Pg::Commands
end

RSpec.describe Rumination::Pg::Commands do
  subject(:dsl) { TestDsl.new }
  describe "create_dump" do
    it "has usable defaults" do
      expect(dsl).to receive(:sh).with("pg_dump --compress=9 --file=dump/path")
      dsl.create_dump "dump/path"
    end

    it "can be reconfigured" do
      allow(Rumination.config.pg).to receive(:create_dump_args) { %w[-O -c -Z 5] }
      expect(dsl).to receive(:sh).with("pg_dump -O -c -Z 5 --file=dump/path")
      dsl.create_dump "dump/path"
    end

    it "expects optional command line flags" do
      expect(dsl).to receive(:sh).with("pg_dump --compress=9 -O -c --file=dump/path")
      dsl.create_dump "dump/path", "-O", "-c"
    end
  end
end
