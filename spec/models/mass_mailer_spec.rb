require File.dirname(__FILE__) + '/../spec_helper'

describe MassMailer do
  before(:each) do
    user_id = users(:brad).id
    @task = Task.new :title => "This is a test", :assignee_id => user_id,
            :creator_id => users(:chris).id, :status => :prioritized
    @task.save!
  end
  it "should deliver to the assignee" do
    @task.mass_mailer.recipients.include?(@task.assignee).should == true
  end
  it "should deliver to the creator" do
    @task.mass_mailer.recipients.include?(@task.creator).should == true
  end
  it "should ignore a user if requested" do
    @task.mass_mailer.ignoring(@task.assignee).recipients.
      include?(@task.assignee).should == false
  end
end
