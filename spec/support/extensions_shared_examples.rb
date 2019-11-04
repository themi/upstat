RSpec.shared_examples "extension data object class" do
  it "succesfully loads records" do
    expect(subject).to be_a(Array)
  end
  it "rows are OpenStruct objects" do
    expect(subject.first).to be_a(OpenStruct)
  end
  it "there are 2 rows" do
    expect(subject.count).to eq(2)
  end
end
