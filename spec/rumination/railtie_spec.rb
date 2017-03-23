RSpec.describe "Rumination::Railtie" do
  context "no rails" do
    it "isn't defined" do
      load "./lib/rumination.rb"
      expect(Rumination.const_defined?("Railtie")).to be_falsy
    end
  end
  context "with rails" do
    around do |example|
      module Rails ; end
      example.call
      Object.send(:remove_const, :Rails)
      Rumination.send(:remove_const, :Railtie)
    end
    it "is defined" do
      load "./lib/rumination.rb"
      expect(Rumination.const_defined?("Railtie")).to be_truthy
    end
  end
end
