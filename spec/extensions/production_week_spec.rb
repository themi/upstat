RSpec.describe Extensions::ProductionWeek do

  describe "#production_beginning_of_week" do
    subject { current_time.production_beginning_of_week }

    context "With date: Wednesday, 20 Nov 2019" do
      before do
        Timecop.freeze(Time.local(2019, 11, 20))
      end
      after do
        Timecop.return
      end
      let(:current_time) { Time.now }

      context "and default production week settings" do
        it "production week starts at Monday 18 Nov 2019" do
          expect(subject.iso8601).to eq('2019-11-18T00:00:00+11:00')
        end
      end

      context "with production week starting on Thur" do
        before do
          Extensions.production_day_of_week = 4
        end
        it "production week starts at Thurs 14 Nov 2019" do
          expect(subject.iso8601).to eq('2019-11-14T00:00:00+11:00')
        end
      end
    end
  end
end
