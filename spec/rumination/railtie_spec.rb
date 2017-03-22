RSpec.describe "Rumination::Railtie" do
  context "no rails" do
    it "isn't defined" do
      load "./lib/rumination.rb"
      expect(Rumination.const_defined?("Railtie")).to be_falsy
    end
  end
  context "with rails" do
    before do
      module Rails ; end
    end
    it "is defined" do
      load "./lib/rumination.rb"
      expect(Rumination.const_defined?("Railtie")).to be_truthy
    end
  end
end
