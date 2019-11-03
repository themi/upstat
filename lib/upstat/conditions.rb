module Upstat
  class Conditions

    class Condition < Struct.new(:condition, :range, :message)
    end

    class << self
      # NOTE: the coditions are not listed in correct sequence (emergency and normal, non-e and danger)
      # deliberately done to allow for correct selection by method select_condition
      CONDITIONS_OF_EXISTENCE = [
        Condition.new("power_change",  nil,                      nil),
        Condition.new(POWER,           nil,                      :normal_in_new_high_range?),
        Condition.new(AFFLUENCE,       1.249..Float::INFINITY,  nil),
        Condition.new(EMERGENCY,      -0.3927..0,                :no_change_over_time?),
        Condition.new(NORMAL,          0..1.249,                nil),
        Condition.new(NON_EXISTENCE,  -Float::INFINITY..-1.249, nil),
        Condition.new(DANGER,         -1.249..-0.3927,          :emergency_over_time?),
        Condition.new("liability",     nil, nil),
        Condition.new("doubt",         nil, nil),
        Condition.new("enemy",         nil, nil),
        Condition.new("treason",       nil, nil),
        Condition.new("confusion",     nil, nil)
      ]

      def select_condition(slope)
        CONDITIONS_OF_EXISTENCE.detect { |s| s.range.cover?(slope) if s.range }
      end

      def custom_conditions
        CONDITIONS_OF_EXISTENCE.select { |s| s.respond_to?(:message) && !s.message.nil? }
      end

      def down_conditions
        [DANGER, EMERGENCY]
      end

      def up_conditions
        [NORMAL, AFFLUENCE]
      end

      def power_conditions
        [AFFLUENCE, POWER]
      end
    end

    attr_accessor :period, :period_history, :all_history, :aggregate_by
    attr_accessor :apparent

    # :period_history is Upstat::DataObject of 12 or more __previous__ data points,order by time_value: :ascending and excluding what is within :period
    # :period is  an Upstat::DataObject of 3 or more subdivisions of the current or upcoming period (eg. if :period_history is weeks, then :period is days)
    # :all_history is a boolean where:
    #   - true = :period_history contains all existing period datasets
    #   - false = :period_history contains a recent subset of all existing data points
    # :aggregate_by is a string containing: "sum", "avg", or any other Math aggregrate method.
    #
    # Example Data: period = Weeks
    #   period_history: [
    #      { time_value: 2019-07-15, y_value: 2 },
    #      { time_value: 2019-07-22, y_value: 10 },
    #      { time_value: 2019-07-29, y_value: 20 },
    #      { time_value: 2019-08-05, y_value: 21 },
    #      { time_value: 2019-08-12, y_value: 19 },
    #      { time_value: 2019-08-19, y_value: 21 },
    #      { time_value: 2019-08-26, y_value: 22 },
    #      { time_value: 2019-09-02, y_value: 20 },
    #      { time_value: 2019-09-09, y_value: 22 },
    #      { time_value: 2019-09-16, y_value: 23 },
    #      { time_value: 2019-09-23, y_value: 22 },
    #      { time_value: 2019-09-30, y_value: 23 },
    #   ]
    #   period: [
    #      { time_value: 2019-09-24, y_value: 3 },
    #      { time_value: 2019-09-25, y_value: 3 },
    #      { time_value: 2019-09-26, y_value: 4 },
    #      { time_value: 2019-09-27, y_value: 5 }
    #      { time_value: 2019-09-28, y_value: 2 }
    #      { time_value: 2019-09-29, y_value: 3 }
    #      { time_value: 2019-09-30, y_value: 4 }
    #   ]
    #
    def initialize(period, period_history=[], all_history=false, aggregate_by="sum")
      @period = period
      @period_history = period_history
      @all_history = all_history
      @aggregate_by = aggregate_by
    end

    # Calculate the condition for the data points within period.
    # This is the first parse, determines the linear regression slope
    # of data points within :period array and then converted to a "condition"
    def apparent_condition
      y_values = list_y_values(period)

      if y_values.size <= 1
        @apparent = NON_EXISTENCE
      else
        trend = Extensions::Trend.new(y_values)
        @apparent = self.class.select_condition(trend.slope).condition
      end
    end

    # This takes into account the period_history data points and calculates
    # based on the following ideas:
    #  - emergency_over_time,
    #  - no_change_over_time, and
    #  - normal_in_new_high_range
    def actual_condition
      return apparent if apparent == AFFLUENCE
      actual = apparent
      self.class.custom_conditions.each do |item|
        if send(item.message)
          actual = item.condition
          break
        end
      end

      actual
    end

    # -------
    protected
    # -------

    def emergency_over_time?
      unless period_history.empty?
        period_history.select { |p| p.apparent == EMERGENCY }.size == OVER_TIME_SIZE
      else
        false
      end
    end

    def no_change_over_time?
      unless period_history.empty?
        period_history.select { |p| p.y_value == period.y_value }.size == OVER_TIME_SIZE
      else
        false
      end
    end

    def normal_in_new_high_range?
      if all_history
        if @apparent == NORMAL
          if recent_power?
            true
          elsif recent_affluence?
            if danger_since?
              false
            else
              true
            end
          end
        end
      else
        false
      end
    end

    # -----
    private
    # -----

    def danger_since?
      ndx = find_recent_history_for(AFFLUENCE)
      since = period_history[ndx].time_value
      period_history.select { |p| p.time_value > since && p.apparent == DANGER }.any?
    end

    def recent_power?
      !find_recent_history_for(POWER).nil?
    end

    def recent_affluence?
      !find_recent_history_for(AFFLUENCE).nil?
    end

    def find_recent_history_for(condition)
      period_history.reverse.index { |p| p.apparent == condition }
    end

    def list_y_values(period)
      period.map { |p| p.y_value }
    end
  end
end
