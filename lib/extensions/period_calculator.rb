module Extensions
  module PeriodCalculator

    attr_accessor :settings, :raw_data

    def initialise(raw_data, options = {})
      @period_klass = period_klass
      @raw_data = raw_data
      @settings = {
        aggregate_by: "sum"
        time_value_field: "time_value",
        y_value_field: "y_value",
        apparent_field: "apparent_condition",
        actual_field: "actual_condition"
      }.merge(options)
    end

    def weekly(date_sample)
      p_start = date_sample.beginning_of_production_week
      p_end = date_sample.end_of_production_week

      calculate_period_data(p_start, p_end)
    end

    def monthly(date_sample)
      p_start = Time.new(date_sample.year, date_sample.month, 1)
      p_end = Date.new(date_sample.year, date_sample.month, -1).to_time

      calculate_period_data(p_start, p_end)
    end

    # -----
    private
    # -----

    def calculate_period_data(p_start, p_end)
      period_rows = select_rows(p_start, p_end)
      stats = Upstat::Conditions.new(period_rows)

      {
        "#{time_value_field}": p_end,
        "#{y_value_field}": aggregate_data(period_rows),
        "#{apparent_field}": stats.apparent_condition
      }

    end

    def aggregate_data(rows)
      rows.map { |r| r.send(y_value_field) }.send(aggregate_by)
    end

    def select_rows(p_start, p_end)
      raw_data.select { |p| p.send(time_value_field) >= p_start && p.send(time_value_field) <= p_end }
    end

    def apparent_field
      settings[:apparent_field]
    end

    def aggregate_by
      settings[:aggregate_by]
    end

    def time_value_field
      settings[:time_value_field]
    end

    def y_value_field
      settings[:y_value_field]
    end
  end
end
