# Lifted from https://github.com/zero-one-software/linear_regression_trend

module Extensions
  class Trend
    attr_accessor :slope, :intercept

    # Pass in an array of values to get the regression on
    def initialize(y_values, non_negative: false)
      @y_values = y_values
      @size     = @y_values.size
      @x_values = (1..@size).to_a
      @no_negs  = non_negative

      #initialize everything to 0
      sum_x  = 0
      sum_y  = 0
      sum_xx = 0
      sum_xy = 0

      # calculate the sums
      @y_values.zip(@x_values).each do |y, x|
        sum_xy += x*y
        sum_xx += x*x
        sum_x  += x
        sum_y  += y
      end

      # calculate the slope
      @slope     = 1.0 * ((@size * sum_xy) - (sum_x * sum_y)) / ((@size * sum_xx) - (sum_x * sum_x))
      @intercept = 1.0 * (sum_y - (@slope * sum_x)) / @size
    end

    # Get the y-axis values of the trend line
    def trend
      @x_values.map { |x| predict(x) }
    end

    # Get the Y value for any given X value
    # from y = mx + b, or
    # y = slope * x + intercept
    def predict(x)
      predicted = @slope * x + @intercept

      return 0 if predicted < 0 and @no_negs
      return predicted
    end

    # Get the "next" value if the sequence
    # was continued one more element
    def next
      predict (@size + 1)
    end

    # Determine the target needed to stabilize
    # the slope back to 0, assuming slope is
    # negative. The target returned will be
    # the number needed to have stabilized slope
    # inclusive of all values in the set
    def stabilize_over_all
      stabilize @y_values
    end

    # Determine the target needed to stabilize
    # the slope back to 0, assuming slope is
    # negative. The target returned will be
    # the number needed to have stabilized slope
    # over a set of values of size n (including
    # the target value
    def stabilize_over_n_values(n)
      values = []
      values = @y_values.last(n-1) if n - 1 >= 0

      stabilize values
    end

    private

    def stabilize(values)
      n      = values.length
      sum    = 0
      target = 0

      values.each_with_index do |value, i|
        sum += (n - (2 * i)) * value
      end

      target = 1.0 * sum / n if n > 0
      target
    end
  end
end
