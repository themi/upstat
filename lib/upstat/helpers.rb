require 'time'

module Upstat
  module Helpers

    ###
    # Aggregate into periods (eg. days into weeks) and calculate the condition
    #
    def calculate_periods(source_data, period_type="weekly", aggregrate_by="sum")
      bop, eop, increment, minimum_date, maximum_date = period_bounds(source_data, period_type)
      periods = [].tap { |collection|
        while bop <= maximum_date
          sub_periods = source_data.select { |row| row.time_value >= bop && row.time_value <= eop }.to_openstruct
          stats = Upstat::Conditions.new(sub_periods, collection, aggregrate_by)
          collection << OpenStruct.new({
            time_value: eop,
            y_value: stats.aggregate_total,
            apparent: stats.apparent_condition,
            actual: stats.actual_condition
          })
          bop, eop = increment.call(bop, eop)
        end
      }
    end

    # -----
    private
    # -----

    def period_bounds(source_data, period_type)
      bop = nil; eop = nil; increment = nil
      minimum_date = source_data.first.time_value
      maximum_date = source_data.last.time_value

      case period_type
      when "weekly"
        bop = minimum_date.production_beginning_of_week
        eop = minimum_date.production_end_of_week
        increment = lambda { |bop, eop| [bop + ( DAY_SECONDS * 7), eop + ( DAY_SECONDS * 7)] }
      when "monthly"
        bop = Time.new(minimum_date.year, minimum_date.month, 1)
        eop = Date.new(minimum_date.year, minimum_date.month, -1).to_time
        increment = lambda { |bop, eop| [bop = Time.new(bop.year, bop.month+1, 1), eop = Date.new(bop.year, bop.month+2, -1).to_time] }
      end

      [bop, eop, increment, minimum_date, maximum_date]
    end
  end
end
