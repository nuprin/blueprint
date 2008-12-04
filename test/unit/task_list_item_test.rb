require 'test_helper'

class TaskListItemTest < ActiveSupport::TestCase

  TASK_TITLES = %w{A B C}

  def setup
    @kristjan = User.create! :name => 'Kristján'
    @monocle  = Project.create! :title => 'Monocle'
    TASK_TITLES.map do |name|
      Task.create! :title => name, :creator => @kristjan,
                   :assignee => @kristjan, :project => @monocle
    end
  end

  def test_project_list_creation
    assert_equal TASK_TITLES, @monocle.task_list.map(&:task).map(&:title)
  end

  def test_assignee_list_creation
    assert_equal TASK_TITLES, @kristjan.task_list.map(&:task).map(&:title)
  end

  def test_changing_assignee_list_updates_project_list
    @kristjan.task_list.all.last.update_position(1)
    assert_equal %w{C A B}, @monocle.task_list.map(&:task).map(&:title)
  end

  def test_changing_project_list_updates_assignee_list
    @monocle.task_list.all.last.update_position(1)
    assert_equal %w{C A B}, @kristjan.task_list.map(&:task).map(&:title)
  end
end
