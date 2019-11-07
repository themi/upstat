RSpec.describe Upstat::Conditions do

  # specify { expect(subject).to respond_to(:template_yaml) }

  specify "down_conditions return danger and emergency" do
    expect(described_class.down_conditions).to eq ["danger","emergency"]
  end

  specify "up_conditions return normal and affluence" do
    expect(described_class.up_conditions).to eq ["normal","affluence"]
  end

  specify "power_conditions return affluence and power" do
    expect(described_class.power_conditions).to eq ["affluence", "power"]
  end

  specify "each processed_state.message should not be nil" do
    expect(described_class.custom_conditions.map {|s| s.message }).to_not include(nil)
  end

  describe "#select_condition" do
    subject(:upstat) { described_class.select_condition(trend_angle) }

    context "with moderate up trend_angle lower limit" do
      let(:trend_angle) { 1.249 }
      specify { expect(upstat.condition).to eq 'affluence' }
    end

    context "with up trend_angle upper limit" do
      let(:trend_angle) { 1.24899999999 }
      specify { expect(upstat.condition).to eq 'normal' }
    end

    context "with up trend_angle lower limit" do
      let(:trend_angle) { 0.000000000001 }
      specify { expect(upstat.condition).to eq 'normal' }
    end

    context "with down trend_angle upper limit" do
      let(:trend_angle) { 0.0 }
      specify { expect(upstat.condition).to eq 'emergency' }
    end

    context "with down trend_angle lower limit" do
      let(:trend_angle) { -0.8 }
      specify { expect(upstat.condition).to eq 'emergency' }
    end

    context "with medium down trend_angle upper limit" do
      let(:trend_angle) { -0.800000001 }
      specify { expect(upstat.condition).to eq 'danger' }
    end

    context "with medium down trend_angle lower limit" do
      let(:trend_angle) { -1.24899999999 }
      specify { expect(upstat.condition).to eq 'danger' }
    end

    context "with moderate down trend_angle upper limit" do
      let(:trend_angle) { -1.2490 }
        specify { expect(upstat.condition).to eq 'non-existence' }
    end
  end
end
