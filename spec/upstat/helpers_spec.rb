RSpec.describe Upstat::Helpers do
  class StorageUtils
    extend Extensions::DataUtils
  end

  class TestHelper
    extend Upstat::Helpers

    def self.raw_data
      [
        # 1st week - non-existence/non-existence
        OpenStruct.new({ time_value: Time.parse("2019-11-01 13:00:00 +1100"), y_value: 3 }),
        # 2nd week - affluence/affluence
        OpenStruct.new({ time_value: Time.parse("2019-11-04 13:00:00 +1100"), y_value: 4 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-05 13:00:00 +1100"), y_value: 8 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-06 13:00:00 +1100"), y_value: 12 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-07 13:00:00 +1100"), y_value: 16 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-08 13:00:00 +1100"), y_value: 20 }),
        # 3rd week - normal/power
        OpenStruct.new({ time_value: Time.parse("2019-11-11 13:00:00 +1100"), y_value: 21 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-12 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-13 13:00:00 +1100"), y_value: 23 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-14 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-15 13:00:00 +1100"), y_value: 24 }),
        # 4th week - emergency/emergency
        OpenStruct.new({ time_value: Time.parse("2019-11-18 13:00:00 +1100"), y_value: 24 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-19 13:00:00 +1100"), y_value: 23 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-20 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-21 13:00:00 +1100"), y_value: 21 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-22 13:00:00 +1100"), y_value: 21 }),
        # 5th week - normal/power
        OpenStruct.new({ time_value: Time.parse("2019-11-25 13:00:00 +1100"), y_value: 21 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-26 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-27 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-28 13:00:00 +1100"), y_value: 23 }),
        OpenStruct.new({ time_value: Time.parse("2019-11-29 13:00:00 +1100"), y_value: 24 }),
        # 6th week - danger/danger
        OpenStruct.new({ time_value: Time.parse("2019-12-02 13:00:00 +1100"), y_value: 24 }),
        OpenStruct.new({ time_value: Time.parse("2019-12-03 13:00:00 +1100"), y_value: 23 }),
        OpenStruct.new({ time_value: Time.parse("2019-12-04 13:00:00 +1100"), y_value: 22 }),
        OpenStruct.new({ time_value: Time.parse("2019-12-05 13:00:00 +1100"), y_value: 20 }),
        OpenStruct.new({ time_value: Time.parse("2019-12-06 13:00:00 +1100"), y_value: 20 }),
        # 7th week - normal/normal
        OpenStruct.new({ time_value: Time.parse("2019-12-08 13:00:00 +1100"), y_value: 21 }),
        OpenStruct.new({ time_value: Time.parse("2019-12-09 13:00:00 +1100"), y_value: 20 }),
        OpenStruct.new({ time_value: Time.parse("2019-12-10 13:00:00 +1100"), y_value: 21 }),
        OpenStruct.new({ time_value: Time.parse("2019-12-11 13:00:00 +1100"), y_value: 21 }),
        OpenStruct.new({ time_value: Time.parse("2019-12-12 13:00:00 +1100"), y_value: 22 }),
      ]
    end
  end

  describe "#calculate_periods" do
    subject { TestHelper.calculate_periods(source_data, period_type, aggregrate_by) }
    let(:source_data) { TestHelper.raw_data }

    context "with aggregate: 'sum' and period: 'weekly' " do
      let(:period_type) { "weekly" }
      let(:aggregrate_by) { "sum" }

      it "returns 4 periods (weeks)" do
        expect(subject.size).to eq 7
      end

      it "first period condition is non-exsistence/non-exsistence" do
        expect(subject[0][:apparent]).to eq "non-existence"
        expect(subject[0][:actual]).to eq "non-existence"
      end

      it "second period condition is affluence/affluence" do
        expect(subject[1][:apparent]).to eq "affluence"
        expect(subject[1][:actual]).to eq "affluence"
      end

      it "third period condition is normal/power" do
        expect(subject[2][:apparent]).to eq "normal"
        expect(subject[2][:actual]).to eq "power"
      end

      it "fourth period condition is emergency/emergency" do
        expect(subject[3][:apparent]).to eq "emergency"
        expect(subject[3][:actual]).to eq "emergency"
      end

      it "fifth period condition is normal/power" do
        expect(subject[4][:apparent]).to eq "normal"
        expect(subject[4][:actual]).to eq "power"
      end

      it "sixth period condition is danger/danger" do
        expect(subject[5][:apparent]).to eq "danger"
        expect(subject[5][:actual]).to eq "danger"
      end

      it "seventh period condition is normal/normal" do
        expect(subject[6][:apparent]).to eq "normal"
        expect(subject[6][:actual]).to eq "normal"
      end

    end
  end

end
