require 'spec_helper'
require 'support/fit/uploaded_activity'

describe Fit::File do
  it "should have a header"
  it "should have records"
  it "should have a CRC"

  context "for a known FIT file" do

    before(:all) do
      @fit_file = described_class.read(StringIO.new(binaray_activity_data))
    end

    describe "active_duration" do
      subject { @fit_file.active_duration }

      it { should == 5483130 }
    end

    describe "distance" do
      subject { @fit_file.distance }

      it { should == 4132004 }
    end

    describe "duration" do
      subject { @fit_file.duration }

      it { should == 10102350 }
    end

    describe "end_time" do
      subject { @fit_file.end_time }

      it { should == 1373889122 }
    end

    describe "start_time" do
      subject { @fit_file.start_time }

      it { should == 1373878839 }
    end
  end
end
