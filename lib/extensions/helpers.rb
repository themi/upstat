require 'time'

module Extensions
  module Helpers

    DAY_SECONDS = 86400

    ###
    # generate a years worth of daily stats with
    # the overall trend in "normal" condition.
    #
    def generate_sample_data(years=1, verbose = true)
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

      days_array
    end

    ###
    # Aggregate into periods (eg. days into weeks) and calculate the condition
    #
    def calculate_periods(source_data, period_type="weekly", aggregrate_by="sum")
      bop, eop, increment, minimum_date, maximum_date = period_bounds(source_data, period_type)
      periods = [].tap { |collection|
        while bop <= maximum_date
          sub_periods = source_data.select { |row| row[:time_value] >= bop && row[:time_value] <= eop }.to_openstruct
          stats = Upstat::Conditions.new(sub_periods, collection, aggregrate_by)
          collection << {
            time_value: eop,
            y_value: stats.aggregate_total,
            apparent: stats.apparent_condition,
            actual: stats.actual_condition
          }
          bop = increment.call(bop)
          eop = increment.call(eop)
        end
      }
    end

    # -----
    private
    # -----

    def period_bounds(source_data, period_type)
      bop = nil; eop = nil; increment = nil
      minimum_date = source_data.first[:time_value]
      maximum_date = source_data.last[:time_value]

      case period_type
      when "weekly"
        bop = minimum_date.production_beginning_of_week
        eop = minimum_date.production_end_of_week
        increment = lambda { |i| i +( DAY_SECONDS * 7) }
      when "monthly"
        bop = Time.new(minimum_date.year, minimum_date.month, 1)
        eop = Date.new(minimum_date.year, minimum_date.month, -1).to_time
        increment = lambda { |i| Time.new(i.year, i.month+1, 1) }
      end

      [bop, eop, increment, minimum_date, maximum_date]
    end
  end
end
