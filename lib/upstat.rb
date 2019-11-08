require 'extensions'

module Upstat
  DAY_SECONDS    = 86400
  OVER_TIME_SIZE = 3
  AFFLUENCE      = "affluence"
  DANGER         = "danger"
  EMERGENCY      = "emergency"
  NON_EXISTENCE  = "non-existence"
  NORMAL         = "normal"
  POWER          = "power"

  class LoadError < StandardError
    # puts "Current failure: #{error.inspect} => Upstat:LoadError"
    # puts "Original failure:  #{error.cause.inspect} => originating error object"
  end
end

require "upstat/version"
require "upstat/production_week"
require "upstat/trend"
require "upstat/conditions"
require "upstat/helpers"
