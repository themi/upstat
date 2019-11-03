module Upstat
  class DataObject
    class << self

      def load_yaml(file_name)
        begin
          localise(YAML.load(File.read(file_name)).to_openstruct)
        rescue => e
          raise e
        end
      end
      alias :load_yml :load_yaml

      def load_json(file_name)
        begin
          localise(JSON.parse(File.read(file_name), symbolize_names: true).to_openstruct)
        rescue => e
          raise e
        end
      end

      private

      def localise(records, time_fields = ['time_value'])
        records.each do |data|
          time_fields.each do
            data.send(time_value) = Time.parse(data.send(time_value)).localtime
          end
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
