require 'test_helper'

class TaskListItemBase < ActiveSupport::TestCase
  def titles(context)
    context.task_list.map(&:task).map(&:title)
  end

  def puts(s)
    RAILS_DEFAULT_LOGGER.info "#!#{s}"
  end
end

class TaskListItemBasicTest < TaskListItemBase

  TASK_TITLES = %w{A B C}

  def setup
    @kristjan = User.create! :name => 'Kristján'
    @blueprint  = Project.create! :title => 'Blueprint'
    TASK_TITLES.each do |name|
      Task.create! :title => name, :creator => @kristjan,
                   :assignee => @kristjan, :project => @blueprint,
                   :status => 'prioritized'
    end
  end

  def test_project_list_creation
    assert_equal TASK_TITLES, titles(@blueprint)
  end

  def test_assignee_list_creation
    assert_equal TASK_TITLES, titles(@kristjan)
  end

  def test_changing_assignee_list_updates_project_list
    @kristjan.task_list.all.last.update_position(1)
    assert_equal %w{C A B}, titles(@blueprint)
  end

  def test_changing_project_list_updates_assignee_list
    @blueprint.task_list.all.last.update_position(1)
    assert_equal %w{C A B}, titles(@kristjan)
  end

  def test_move_to_bottom_of_assignee
    @kristjan.task_list.all.first.update_position(@kristjan.task_list.size+1)
    @kristjan.reload
    assert_equal %w{B C A}, titles(@kristjan)
    assert_equal %w{B C A}, titles(@blueprint)
  end


  def test_move_to_bottom_of_project
    @blueprint.task_list.all.first.update_position(@blueprint.task_list.size+1)
    @blueprint.reload
    assert_equal %w{B C A}, titles(@blueprint)
    assert_equal %w{B C A}, titles(@kristjan)
  end

end

class TaskListItemAdvancedTest < TaskListItemBase

  TASK_TITLES = [%w{A B C}, %w{1 2 3}]

  def setup
    @kristjan = User.create! :name => 'Kristján'
    @blueprint  = Project.create! :title => 'Blueprint'
    @redink = Project.create! :title => 'Redink'
    TASK_TITLES[0].each do |name|
      Task.create! :title => name, :creator => @kristjan,
                   :assignee => @kristjan, :project => @blueprint,
                   :status => 'prioritized'
    end
    TASK_TITLES[1].each do |name|
      Task.create! :title => name, :creator => @kristjan,
                   :assignee => @kristjan, :project => @redink,
                   :status => 'prioritized'
    end
  end

  def test_project_list_creation
    assert_equal TASK_TITLES[0], titles(@blueprint)
    assert_equal TASK_TITLES[1], titles(@redink)
  end

  def test_assignee_list_creation
    assert_equal TASK_TITLES[0] + TASK_TITLES[1], titles(@kristjan)
  end
  
  def test_move_to_bottom_of_project
    @blueprint.task_list.all.first.update_position(@blueprint.task_list.size+1)
    @blueprint.reload
    assert_equal %w{B C A}, titles(@blueprint)
    assert_equal %w{B C A 1 2 3}, titles(@kristjan)
  end
end
