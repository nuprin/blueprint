require File.dirname(__FILE__) + '/../spec_helper'

describe "a generic task email", :shared => true do
  include ActionController::UrlWriter

  it "should be from blueprint's generic email address" do
    @mail.from[0].should == TaskMailer::FROM_EMAIL
  end

  it "should have the generic task subject" do
    @mail.subject.should == "(##{@task.id}) #{@task.title}"
  end

  it "should have link to the task in the body" do
    @mail.body.include?(task_path(@task)).should == true
  end  
end

describe "The task creation email" do
  before(:each) do 
    @task = tasks(:one)
    @mail = TaskMailer.create_task_creation(@task.assignee, @task)
  end

  it_should_behave_like "a generic task email"

  it "should appear to be from the creator" do
    @task.creator.name.should == @mail.from_addrs[0].name
  end
end

describe "The task due date changed email" do
  before(:each) do 
    @task = tasks(:one)
    @task.editor = users(:chris)
    @mail = TaskMailer.create_task_due_date_changed(@task.assignee, @task)
  end

  it_should_behave_like "a generic task email"

  it "should appear to be from the editor" do
    @task.editor.name.should == @mail.from_addrs[0].name
  end
end

describe "The task comment email" do
  before(:each) do 
    @comment = comments(:one)
    @task = @comment.commentable
    @mail = TaskMailer.create_task_comment(@task.assignee, @task, @comment)
  end

  it_should_behave_like "a generic task email"

  it "should appear to be from the comment author" do
    @comment.author.name.should == @mail.from_addrs[0].name
  end
end

describe "The task reassignment email" do
  before(:each) do 
    @task = tasks(:one)
    @task.editor = users(:chris)
    @mail = TaskMailer.create_task_reassignment(@task.assignee, @task)
  end

  it_should_behave_like "a generic task email"
  
  it "should appear to be from the editor" do
    @task.editor.name.should == @mail.from_addrs[0].name
  end
end
