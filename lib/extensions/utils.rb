
module Extensions
  module Utils

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

  end
end
