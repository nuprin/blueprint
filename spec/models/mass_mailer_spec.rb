require File.dirname(__FILE__) + '/../spec_helper'

describe MassMailer do
  before(:each) do 
    user_id = users(:brad).id
    @task = Task.new :title => "This is a test", :assignee_id => user_id
    @task.subscriptions.build(:user_id => user_id)
  end
  it "should deliver to a subscriber" do
    @task.mass_mailer.recipients.should == [@task.assignee]
  end
  it "should ignore a user if requested" do
    @task.mass_mailer.ignoring(@task.assignee).recipients.
      should be_empty
  end
end
