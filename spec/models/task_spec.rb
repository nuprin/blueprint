require File.dirname(__FILE__) + '/../spec_helper'

describe Task do
  before(:each) do
    @task = Task.new(:title => "This is a test", :creator_id => users(:brad).id,
      :status => "prioritized")
  end

  it "should have a title and a creator" do
    @task.valid?.should == true
  end

  it "should cc the assignee when created" do
    @task.assignee_id = users(:chris).id
    @task.save
    @task.subscriptions.map(&:user).include?(users(:chris)).should == true
  end
end

