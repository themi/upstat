# frozen_string_literal: true

require 'time'

module Upstat # no-doc
  # variables specifying the production hour and day
  # defaults to 0 o'clock on monday morning (or midnight Sunday)
  def self.production_hour_of_day
    ::Thread.current[:production_hour_of_day] || 0
  end

  def self.production_hour_of_day=(hour=0)
    ::Thread.current[:production_hour_of_day] = hour
  end

  def self.production_day_of_week
    ::Thread.current[:production_day_of_week] || 1
  end

  def self.production_day_of_week=(day=1)
    ::Thread.current[:production_day_of_week] = day
  end

  # Syntax:
  #   Time.now.production_beginning_of_week => Object<Time>
  #   Time.now.production_end_of_week => Object<Time>
  #
  # Usage:
  #
  #   FIRST! initialise varables on app bootup:
  #
  #     # defaults to 0 o'clock Monday morning (or Midnight Sunday)
  #     Upstat.production_hour_of_day = 14 # default is 0
  #     Upstat.production_day_of_week = 4  # default is 1
  #
  #   Then:
  #
  #     Time.now.production_end_of_week.strftime("%Y-%m-%d") => "2019-08-01"
  #
  module ProductionWeek
    SECONDS_PER_DAY  = 86400
    SECONDS_PER_HOUR = 3600
    # Returns a <Time> object specifying the date and time of the
    # start of your production week relative to the current system
    # date, time and zone
    #
    def production_beginning_of_week
      bow_time = Upstat.production_hour_of_day * SECONDS_PER_HOUR

      today = Time.new(self.year, self.month, self.day)

      time_offset = (Time.now.to_i - today.to_i) - bow_time

      bow_day = today - (((today.wday - Upstat.production_day_of_week) % 7) * SECONDS_PER_DAY)

      if time_offset < 0
        bow_day - (7 * SECONDS_PER_DAY) + bow_time
      else
        bow_day + bow_time
      end
    end
    alias :pbow :production_beginning_of_week

    # Returns a <Time> object specifying the date and time of the
    # end of your production week relative to the current system
    # date, time and zone
    #
    def production_end_of_week
      production_beginning_of_week + (7 * SECONDS_PER_DAY) - 1
    end
    alias :peow :production_end_of_week
  end
end

class Time
  include Upstat::ProductionWeek
end
