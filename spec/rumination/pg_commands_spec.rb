require "spec_helper"

class Dsl
  include Rumination::Pg::Commands
  def sh

  end
end

RSpec.describe Rumination::Pg::Commands do
  subject(:dsl) { Dsl.new }
  describe "create_dump" do
    it "has usable defaults" do
      expect(dsl).to receive(:sh).with("pg_dump --compress=9 --file=dump/path")
      dsl.create_dump "dump/path"
    end
  end
end
