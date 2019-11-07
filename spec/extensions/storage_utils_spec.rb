RSpec.describe Extensions::StorageUtils do
  class StorageUtils
    extend Extensions::StorageUtils
  end

  describe "public methods defined" do
    it "has 'get_yaml'" do
      expect(StorageUtils.respond_to?("get_yaml"))
    end

    it "has 'get_json'" do
      expect(StorageUtils.respond_to?("get_json"))
    end

    it "has 'save_yaml'" do
      expect(StorageUtils.respond_to?("save_yam;"))
    end
  end

  describe "#get_yaml" do
    subject { StorageUtils.get_yaml(file_name) }

    let(:file_name) { File.join(File.dirname(__FILE__), "../support/data/yaml_test.yml") }
    it_behaves_like "extension data object class"
  end

  describe "#get_json" do
    subject { StorageUtils.get_json(file_name) }

    let(:file_name) { File.join(File.dirname(__FILE__), "../support/data/json_test.json") }
    it_behaves_like "extension data object class"
  end

end
