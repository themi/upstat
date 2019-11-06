require 'time'
require 'yaml'

module Extensions
  module StorageUtils

    def open(file_name)
      if defined?(ActiveRecord) && file_name.class.ancestors.include?(ActiveRecord::Base)
        file_name

      elsif file_name.is_a?(String)
        ename = File.extname(File.expand_path(file_name))

        data = if [".yaml", ".yml"].include?(ename)
          get_yaml(file_name)
        elsif [".json"].include?(ename)
          get_json(file_name)
        end
        DataTable.new(data)

      elsif file_name.is_a?(Array)
        DataTable.new(file_name.to_openstruct)

      end
    end

    def get_yaml(file_name, time_fields=["time_value"])
      begin
        data_table = YAML.load(File.read(file_name)).to_openstruct
        localise(data_table, time_fields)
        data_table
      rescue => e
        raise Upstat::LoadError.new("Error occured while loading YAML file #{file_name}")
      end
    end

    def get_json(file_name, time_fields=["time_value"])
      begin
        data_table = JSON.parse(File.read(file_name), symbolize_names: true).to_openstruct
        localise(data_table, time_fields)
        data_table
      rescue => e
        raise Upstat::LoadError.new("Error occured while loading JSON file #{file_name}")
      end
    end

    def save_yaml(data_table, file_name, time_fields=[:time_value])
      utcise(data_table, time_fields)
      begin
        File.open(file_name, 'w') do |f|
          f.write data_table.to_yaml
        end
      rescue => e
        raise Upstat::LoadError.new("Error occured while saving YAML file #{file_name}")
      end
    end

    # -----
    private
    # -----

    def utcise(data_table, file_name, time_fields=[:time_value])
      set_storage_time_zone(data_table, time_fields, "utc")
    end

    def localise(data_table, file_name, time_fields=[:time_value])
      set_storage_time_zone(data_table, time_fields, "localtime")
    end

    def set_storage_time_zone(data_table, time_fields, time_system)
      data_table.each do |row|
        time_fields.each do |field|
          row[field] = Time.parse(row[field].to_s).send(time_system).iso8601
        end
      end
    end

  end
end
