require File.dirname(__FILE__) + '/../spec_helper'

describe Task do
  before(:each) do 
    @task = Task.new(:title => "This is a test", :creator_id => users(:brad).id)
  end
  it "should have a title and a creator" do
    @task.valid?.should == true
  end
  it "should not notify the editor on completion" do
    mailer = @task.mass_mailer
    @task.editor = users(:chris)
    @task.stubs(:save!)

    @task.expects(:mass_mailer).returns(mailer)
    mailer.expects(:ignoring).with(@task.editor).returns(mailer)

    @task.complete!
  end
  it "should not notify the editor on reassignment" do
    mailer = @task.mass_mailer
    @task.editor = users(:chris)

    @task.stubs(:assignee_id_changed?).returns(true)
    @task.expects(:mass_mailer).returns(mailer)
    mailer.expects(:ignoring).with(@task.editor).returns(mailer)

    @task.notify_subscribers
  end
  it "should not notify the editor on due date change" do
    mailer = @task.mass_mailer
    @task.editor = users(:chris)

    @task.stubs(:due_date_changed?).returns(true)
    @task.expects(:mass_mailer).returns(mailer)
    mailer.expects(:ignoring).with(@task.editor).returns(mailer)

    @task.notify_subscribers
  end
end
