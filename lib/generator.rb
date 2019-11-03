#!/usr/bin/env ruby
require "bundler/setup"
require "upstat"

require "byebug"
require 'yaml'
require 'time'

BASE_DATA_FILE = "./spec/support/data/raw.yml"
HISTORY_DATA_FILE = "./spec/support/data/history.yml"
DAY_SECONDS = 86400
WEEK_SECONDS = 604800

def generate_raw_data(file_name, years=1)
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
    if value < 1
      base = base + increment
    end
    if value > 9
      base = base - increment
    end
    if large_increment > 99
      base = base + (increment * 4)
    end
    days_array << { time_value: now.strftime("%Y-%m-%d"), y_value: value+base }
    now = now + DAY_SECONDS
  end

  File.open(file_name, 'w') do |f|
    f.write days_array.to_yaml
  end
end

def load_data()
  period_data = YAML.load(File.read(BASE_DATA_FILE))
  period_data.each do |data|
    data[:time_value] = Time.parse(data[:time_value])
  end
  period_data
end

def save_period_data(period_hash)
  File.open(HISTORY_DATA_FILE, 'w') do |f|
    f.write period_hash.to_yaml
  end
end

def set_period_bounds(raw_data, period_length)
  start = raw_data.first[:time_value]
  last = raw_data.last[:time_value]
  bop = nil; eop = nil; finish = nil

  case period_length
  when :week
    bop = start.production_beginning_of_week
    eop = start.production_end_of_week
    finish = raw_data.last[:time_value].production_end_of_week
  when :month
    bop = Time.new(start.year, start.month, 1)
    eop = Time.new(start.year, start.month+1, 1) - DAY_SECONDS
    finish = Time.new(last.year, last.month+1, 1) - DAY_SECONDS
  end

  [bop, eop, finish]
end

def increment_period(period_length, bop, eop)
  case period_length
  when :week
    bop = bop + WEEK_SECONDS
    eop = eop + WEEK_SECONDS
  when :month
    bop = Time.new(bop.year, bop.month+1, 1)
    eop = Time.new(eop.year, eop.month+2, 1) - DAY_SECONDS
  end

  [bop, eop]
end

def generate_periods(raw_data, period_length = :week, aggregate_by = :sum)
  bop, eop, finish = set_period_bounds(raw_data, period_length)

  periods = []
  while raw_data.detect {|p| eop <= finish }
    raw_row = raw_data.select { |p| p[:time_value] >= bop && p[:time_value] <= eop }
    stat = Upstat::Conditions.new(raw_row)
    period_row = { time_value: eop, y_value: raw_row.map { |p| p[:y_value] }.send(aggregate_by), apparent: stat.apparent_condition }

    periods << period_row
    puts period_row

    bop, eop = increment_period(period_length, bop, eop)
  end

  save_period_data(periods)
end

def generate_history(period_data)

end

# generate_raw_data(BASE_DATA_FILE)
# generate_periods(load_data(BASE_DATA_FILE))
generate_history(load_data(HISTORY_DATA_FILE))
