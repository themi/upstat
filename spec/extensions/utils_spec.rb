RSpec.describe Extensions::Utils do
  class TestUtils
    include Extensions::Utils
  end

  describe "public methods defined" do
    it "has 'get_yaml'" do
      expect(TestUtils.new.respond_to?("get_yaml"))
    end

    it "has 'get_json'" do
      expect(TestUtils.new.respond_to?("get_json"))
    end

    it "has 'save_yaml'" do
      expect(TestUtils.new.respond_to?("save_yam;"))
    end
  end

  describe "#get_yaml" do
    subject { TestUtils.new.get_yaml(file_name) }

    let(:file_name) { File.join(File.dirname(__FILE__), "../support/data/yaml_test.yml") }
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

  describe "#get_json" do
    subject { TestUtils.new.get_json(file_name) }

    let(:file_name) { File.join(File.dirname(__FILE__), "../support/data/json_test.json") }
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

end
