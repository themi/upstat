module Upstat
  class Conditions

    class Condition < Struct.new(:condition, :range, :message)
    end

    class << self
      # NOTES:
      #   1. The coditions are not listed in correct sequence (emergency and normal, non-e and danger)
      #   deliberately done since range.cover? is a kinda like an "overlap" - the test value can be true
      #   for more than one range, thus they have been ordered to fit the desired outcome
      #
      #   2. The actual ranges are arbituary, based on my interpretation on what slope suits the condition.
      #   The method is based on my judgement and not any specific calculation (if one even exists).
      #
      CONDITIONS_OF_EXISTENCE = [
        Condition.new("power_change",  nil,                      nil),
        Condition.new(POWER,           nil,                      :normal_in_new_high_range?),
        Condition.new(AFFLUENCE,       1.249..Float::INFINITY,  nil),
        Condition.new(EMERGENCY,      -0.8..0,                :no_change_over_time?),
        Condition.new(NORMAL,          0..1.249,                nil),
        Condition.new(NON_EXISTENCE,  -Float::INFINITY..-1.249, nil),
        Condition.new(DANGER,         -1.249..-0.8,          :emergency_over_time?),
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

    attr_accessor :period, :period_history, :aggregate_by, :all_history
    attr_accessor :apparent, :aggregate_total, :y_values

    # :period_history is an Array(OpenStruct) of 12 or more __previous__
    #    data points,order by time_value: :ascending and excluding what
    #    is within :period.
    # :period is an Array(OpenStruct) of 3 or more period subdivisions
    #    of the current or upcoming period (eg. if :period_history is
    #    weeks, then :period data points are days). Points must be evenly
    #    distributed even if you have to insert missing points with an 'mean' value.
    # :aggregate_by is a string eg. "sum", "avg", default is "sum"
    # :all_history is a boolean, default is true, where:
    #   - true = :period_history contains all existing period datasets
    #   - false = :period_history contains a recent subset of all existing data points
    #
    def initialize(period, period_history=[], aggregate_by="sum", all_history=true)
      @period = period
      @period_history = period_history
      @aggregate_by = aggregate_by
      @all_history = all_history
      @y_values = list_y_values(period)
      @aggregate_total = y_values.send(aggregate_by)
    end

    # Calculate the condition for the data points within period.
    # This is the first parse, determines the linear regression slope
    # of data points within :period array and then converted to a "condition"
    def apparent_condition
      if y_values.size < OVER_TIME_SIZE
        @apparent = NON_EXISTENCE
      else
        trend = Trend.new(y_values)
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
        period_history.reverse[0..2].select { |p| p.y_value == aggregate_total }.size == OVER_TIME_SIZE
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
            !danger_since?
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
      if (ndx = find_recent_history_for(AFFLUENCE))
        since = period_history[ndx].time_value
        period_history.select { |p| p.time_value > since && p.apparent == DANGER }.any?
      else
        false
      end
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
