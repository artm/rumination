require "support/rake"

RSpec.describe "deploy:env" do
  include_context "rake"
  it "outputs target name" do
    expect { task.invoke }.to output(/# Loading 'development'/).to_stdout
  end

  it "raises UnknownTarget when that is the case" do
    expect do
      expect { task.invoke "unknown_target" }.to output(/# Loading 'unknown_target'/).to_stdout
    end.to raise_error Rumination::Deploy::UnknownTarget
  end
end
