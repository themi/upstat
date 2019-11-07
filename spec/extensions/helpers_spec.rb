RSpec.describe Extensions::Helpers do
  class StorageUtils
    extend Extensions::StorageUtils
  end

  class TestHelper
    extend Extensions::Helpers

    def self.raw_hash
      [
        # 1st week - non-existence/non-existence
        OpenStruct.new({ time_value: Time.parse("2018-11-03 13:00:00 +1100"), y_value: 3 }),
        # 2nd week - affluence/affluence
        OpenStruct.new({ time_value: Time.parse("2018-11-04 13:00:00 +1100"), y_value: 4 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-05 13:00:00 +1100"), y_value: 8 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-06 13:00:00 +1100"), y_value: 12 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-07 13:00:00 +1100"), y_value: 16 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-08 13:00:00 +1100"), y_value: 20 }),
        # 3rd week - normal/power
        OpenStruct.new({ time_value: Time.parse("2018-11-11 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-12 13:00:00 +1100"), y_value: 23 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-13 13:00:00 +1100"), y_value: 23 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-14 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-15 13:00:00 +1100"), y_value: 24 }),
        # 4th week - emergency/emergency
        OpenStruct.new({ time_value: Time.parse("2018-11-18 13:00:00 +1100"), y_value: 23 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-19 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-20 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-21 13:00:00 +1100"), y_value: 21 }),
        OpenStruct.new({ time_value: Time.parse("2018-11-22 13:00:00 +1100"), y_value: 20 }),
      ]
    end
  end

  # Use this to tweak the CONDITIONS_OF_EXISTENCE ranges in file 'lib/upstat/conditions.rb'
  # Tweak the y_values above and compare the outcomes.
  describe "#calculate_periods" do
    subject { TestHelper.calculate_periods(source_data, period_type, aggregrate_by) }
    let(:source_data) { TestHelper.raw_hash }

    context "with aggregate: 'sum' and period: 'weekly' " do
      let(:period_type) { "weekly" }
      let(:aggregrate_by) { "sum" }

      it "returns 4 periods (weeks)" do
        expect(subject.size).to eq 4
      end

      it "first period condition is non-exsistence" do
        expect(subject[0][:apparent]).to eq "non-existence"
      end

      it "second period condition is affluence" do
        expect(subject[1][:apparent]).to eq "affluence"
      end

      it "third period condition is normal" do
        expect(subject[2][:apparent]).to eq "normal"
      end

      it "fourth period condition is emergency" do
        expect(subject[3][:apparent]).to eq "emergency"
      end
    end
  end

end
