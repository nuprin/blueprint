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
    list_titles(@kristjan.task_list.all.first.list).should == TASK_TITLES
  end

  it "should have the correct contextual list" do
    list_titles(@kristjan.task_list.all.first.contextual_list).should == 
      TASK_TITLES                 
  end

  it "should update the project list if the assignee list changes" do
    @kristjan.task_list.all.last.update_position(1)
    titles(@blueprint).should == %w{C A B}
  end
  
  it "should update the assignee list if the project list changes" do
    @blueprint.task_list.all.last.update_position(1)
    titles(@kristjan).should == %w{C A B}
  end
  
  it "should update lists correctly when assignee moves a task to the bottom" do
    @kristjan.task_list.all.first.update_position(@kristjan.task_list.size+1)
    @kristjan.reload
    titles(@kristjan).should == %w{B C A}
    titles(@blueprint).should == %w{B C A}
  end

  it "should update lists correctly when project moves a task to the bottom" do
    @blueprint.task_list.all.first.update_position(@blueprint.task_list.size+1)
    @blueprint.reload
    titles(@kristjan).should == %w{B C A}
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
    list_titles(@kristjan.task_list.all.first.list).should == %w{A B C 1 2 3}
  end

  it "should have a matching contextual list" do
    list_titles(@kristjan.task_list.all.first.contextual_list).should ==
      %w{A B C}                 
    list_titles(@kristjan.task_list.all.last.contextual_list).should ==
      %w{1 2 3}
  end
  
  it "should update the assignee's list when the project position changes" do
    @blueprint.task_list.all.first.update_position(@blueprint.task_list.size)
    @blueprint.reload
    titles(@blueprint).should == %w{B C A}
    titles(@kristjan).should == %w{B C A 1 2 3}
  end

  it "should update the project's list when the assignee position changes" do  
    @kristjan.task_list.all.first.update_position(3)
    @kristjan.reload
    titles(@kristjan).should == %w{B C A 1 2 3}
    titles(@blueprint).should == %w{B C A}
  end

  it "should update the lists when the priority of a task increases by 1" do 
    @blueprint.task_list.all.first.update_position(@blueprint.task_list.size)
    @kristjan.task_list[2].update_position(@blueprint.task_list.size-1)
    @blueprint.reload; @kristjan.reload
    titles(@kristjan).should == %w{B A C 1 2 3}
    titles(@blueprint).should == %w{B A C}
  end
end
