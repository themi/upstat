module Upstat
  class DataObject
    class << self

      def load_yaml(file_name)
        begin
          verify(YAML.load(File.read(file_name)).to_openstruct)
        rescue => e
          raise e
        end
      end
      alias :load_yml :load_yaml

      def load_json(file_name)
        begin
          verify(JSON.parse(File.read(file_name), symbolize_names: true).to_openstruct)
        rescue => e
          raise e
        end
      end

      private

      def verify(records)
        records.each do |data|
          data.time_value = Time.parse(data.time_value) if data.time_value.is_a?(String)
        end
        records
      end
    end

    attr_reader :records

    def initialize(records=[])
      @records = records
    end

    def add(**attribs)
      records << attribs.to_openstruct
    end
  end
end
