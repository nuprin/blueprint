require 'test_helper'

class TaskListItemTest < ActiveSupport::TestCase

  TASK_TITLES = %w{A B C}

  def setup
    @kristjan = User.create! :name => 'Kristján'
    @blueprint  = Project.create! :title => 'Monocle'
    TASK_TITLES.map do |name|
      Task.create! :title => name, :creator => @kristjan,
                   :assignee => @kristjan, :project => @blueprint
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

  def titles(context)
    context.task_list.map(&:task).map(&:title)
  end
end
