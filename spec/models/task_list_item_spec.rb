require File.dirname(__FILE__) + '/../spec_helper'

module TaskListItemBase
  def titles(context)
    list_titles(context.task_list)
  end

  def list_titles(list)
    list.map {|li| li.task.title}
  end
end

describe TaskListItem, " of basic complexity" do
  include TaskListItemBase
  TASK_TITLES = %w{A B C}

  def setup
    @kristjan = User.create! :name => 'Kristján'
    @blueprint  = Project.create! :title => 'Blueprint'
    TASK_TITLES.each do |name|
      Deliverable.create! :title => name, :creator => @kristjan,
                          :assignee => @kristjan, :project => @blueprint,
                          :status => 'prioritized'
    end
  end

  it "should have a project task list with correct titles" do
    titles(@blueprint).should == TASK_TITLES
  end
  
  it "should have a user task list with correct titles" do
    titles(@kristjan).should == TASK_TITLES
  end

  it "should have a correct list" do
    list_titles(@kristjan.task_list.all).should == TASK_TITLES
  end

  it "should update lists correctly when assignee moves a task to the bottom" do
    @kristjan.task_list.all.first.insert_at(@kristjan.task_list.size+1)
    @kristjan.reload
    titles(@kristjan).should == %w{B C A}
  end

  it "should update lists correctly when project moves a task to the bottom" do
    @blueprint.task_list.all.first.insert_at(@blueprint.task_list.size+1)
    @blueprint.reload
    titles(@blueprint).should == %w{B C A}
  end

end

describe TaskListItem, " of mild complexity" do
  include TaskListItemBase
  # Warning: Constants are globally defined in rspec :(.
  MORE_TASK_TITLES = [%w{A B C}, %w{1 2 3}]

  def setup
    @kristjan = User.create! :name => 'Kristján'
    @blueprint  = Project.create! :title => 'Blueprint'
    @redink = Project.create! :title => 'Redink'
    MORE_TASK_TITLES[0].each do |name|
      Deliverable.create! :title => name, :creator => @kristjan,
                          :assignee => @kristjan, :project => @blueprint,
                          :status => 'prioritized'
    end
    MORE_TASK_TITLES[1].each do |name|
      Deliverable.create! :title => name, :creator => @kristjan,
                          :assignee => @kristjan, :project => @redink,
                          :status => 'prioritized'
    end
  end
  
  it "should have the correct project lists" do
    MORE_TASK_TITLES[0].should == titles(@blueprint)
    MORE_TASK_TITLES[1].should == titles(@redink)
  end

  it "should have the correct assignee list" do
    (MORE_TASK_TITLES[0] + MORE_TASK_TITLES[1]).should == titles(@kristjan)
  end

  it "should have the correct list" do
    list_titles(@kristjan.task_list.all).should == %w{A B C 1 2 3}
  end
  
  it "should be reordered when the project position changes" do
    @blueprint.task_list.all.first.insert_at(@blueprint.task_list.size)
    @blueprint.reload
    titles(@blueprint).should == %w{B C A}
  end

  it "should be reordered when the assignee position changes" do  
    @kristjan.task_list.all.first.insert_at(3)
    @kristjan.reload
    titles(@kristjan).should == %w{B C A 1 2 3}
  end

end
