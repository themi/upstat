RSpec.describe Upstat::ProductionWeek do

  describe "#production_beginning_of_week" do
    subject { current_time.production_beginning_of_week }

    context "With date: 1:45pm Wednesday, 20 Nov 2019 EDST (Syd/Australia Daylight Savings)" do
      before do
        Timecop.freeze(Time.new(2019, 11, 20, 13, 45, 0, "+11:00"))
      end
      after do
        Timecop.return
        Upstat.production_day_of_week = 0
        Upstat.production_hour_of_day = 0
      end
      let(:current_time) { Time.now }

      context "and default production week settings" do
        it "production week starts at Midnight Sunday 17 Nov 2019" do
          expect(subject.iso8601).to eq('2019-11-17T00:00:00+11:00')
        end
      end

      context "with production week starting on Thur" do
        before do
          Upstat.production_day_of_week = 4
        end
        it "production week starts at Midnight Thurs 14 Nov 2019" do
          expect(subject.iso8601).to eq('2019-11-14T00:00:00+11:00')
        end
      end

      context "with production week starting on 2pm Wed" do
        before do
          Upstat.production_day_of_week = 3
          Upstat.production_hour_of_day = 14
        end
        it "production week starts at 2pm Wed 13 Nov 2019" do
          expect(subject.iso8601).to eq('2019-11-13T14:00:00+11:00')
        end
      end

      context "with production week starting on 12pm Wed" do
        before do
          Upstat.production_day_of_week = 3
          Upstat.production_hour_of_day = 10
        end
        it "production week starts at 10am Wed 20 Nov 2019" do
          expect(subject.iso8601).to eq('2019-11-20T10:00:00+11:00')
        end
      end
    end
  end
end
