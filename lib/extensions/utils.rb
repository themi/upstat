require 'time'
require 'yaml'

module Extensions
  module Utils

    DAY_SECONDS = 86400

    ###
    # generate a years worth of daily stats with
    # the overall trend in "normal" condition.
    #
    def generate_sample_data(file_name, years, verbose = true)
      now = Time.now
      date_start = Time.new(now.year-years, now.month, now.day)
      date_end = Time.new(now.year, now.month, now.day)

      increment = 3
      base = 0
      days_array = []
      now = date_start
      while now <= date_end
        large_increment = rand(100)
        value = rand(10)

        # occasional upstat
        if value < 1
          base = base + increment
        end

        # occasional downstat
        if value > 9
          base = base - increment
        end

        # occasional spurt of affluence
        if large_increment > 99
          base = base + (increment * 4)
        end

        days_array << { time_value: now, y_value: value+base }
        now = now + DAY_SECONDS
      end

      save_yaml(days_array, file_name)

      puts "Raw (daily) stats saved to file: #{file_name}" if verbose
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
