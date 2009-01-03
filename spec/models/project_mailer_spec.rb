require File.dirname(__FILE__) + '/../spec_helper'

describe "a generic initiative email", :shared => true do
  include ActionController::UrlWriter

  it "should be from blueprint's generic email address" do
    @mail.from[0].should == TaskMailer::FROM_EMAIL
  end

  it "should have a subject prepended with the title" do
    RAILS_DEFAULT_LOGGER.info "#{@mail.subject}"
    @mail.subject.include?("[#{@project.title}]").should == true
  end

  it "should have link to the initiative in the body" do
    @mail.body.include?(project_path(@project)).should == true
  end  
end

describe "A new spec comment email" do
  before(:each) do 
    @comment = comments(:two)
    @project = @comment.commentable
    recipient = users(:chris)
    @mail =
      ProjectMailer.create_new_comment(recipient, @project, @comment)
  end

  it_should_behave_like "a generic initiative email"

  it "should appear to be from the comment author" do
    @comment.author.name.should == @mail.from_addrs[0].name
  end
end
