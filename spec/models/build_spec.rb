require 'spec_helper'

describe Build do
  it "has status passed if all results passed" do
    result_1 = stub_model Result, status_id: Result::STATUS[:passed]
    result_2 = stub_model Result, status_id: Result::STATUS[:passed]
    build = Build.new results: [result_1, result_2]
    build.status.should eql(:passed)
  end

  it "has status busy if any results is busy" do
    result_1 = stub_model Result, status_id: Result::STATUS[:busy]
    result_2 = stub_model Result, status_id: Result::STATUS[:pending]
    build = Build.new results: [result_1, result_2]
    build.status.should eql(:busy)
  end

  it "has status failed if any results is busy" do
    result_1 = stub_model Result, status_id: Result::STATUS[:failed]
    result_2 = stub_model Result, status_id: Result::STATUS[:skipped]
    build = Build.new results: [result_1, result_2]
    build.status.should eql(:failed)
  end

  it "delegates start_time and end_time to results" do
    result = stub_model Result
    build = Build.new :results => [result]
    result.should_receive(:start_time)
    build.start_time
    result.should_receive(:end_time)
    build.end_time
  end

  it "can be skipped" do
    result = stub_model Result
    build = Build.new :results => [result]
    build.skip!
    result.skipped?.should be_true
  end
end
