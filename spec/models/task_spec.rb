require File.dirname(__FILE__) + '/../spec_helper'

describe Task do
  before(:each) do 
    @task = Task.new(:title => "This is a test", :creator_id => users(:brad).id)
  end
  it "should have a title and a creator" do
    @task.valid?.should == true
  end
end
