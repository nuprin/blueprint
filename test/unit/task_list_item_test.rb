require 'test_helper'

class TaskListItemBase < ActiveSupport::TestCase
  def titles(context)
    list_titles(context.task_list)
  end

  def list_titles(list)
    list.map {|li| li.task.title}
  end

  def puts(s)
    RAILS_DEFAULT_LOGGER.info "#!#{s}"
  end
end

class TaskListItemEasyTest < TaskListItemBase

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

  def test_project_list_creation
    assert_equal TASK_TITLES, titles(@blueprint)
  end

  def test_assignee_list_creation
    assert_equal TASK_TITLES, titles(@kristjan)
  end

  def test_list
    assert_equal %w{A B C}, list_titles(@kristjan.task_list.all.first.list)
  end

  def test_contextual_list_matches
    assert_equal %w{A B C},
                 list_titles(@kristjan.task_list.all.first.contextual_list)
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

class TaskListItemMediumTest < TaskListItemBase

  TASK_TITLES = [%w{A B C}, %w{1 2 3}]

  def setup
    @kristjan = User.create! :name => 'Kristján'
    @blueprint  = Project.create! :title => 'Blueprint'
    @redink = Project.create! :title => 'Redink'
    TASK_TITLES[0].each do |name|
      Deliverable.create! :title => name, :creator => @kristjan,
                          :assignee => @kristjan, :project => @blueprint,
                          :status => 'prioritized'
    end
    TASK_TITLES[1].each do |name|
      Deliverable.create! :title => name, :creator => @kristjan,
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

  def test_list
    assert_equal %w{A B C 1 2 3},
                 list_titles(@kristjan.task_list.all.first.list)
  end

  def test_contextual_list_matches
    assert_equal %w{A B C},
                 list_titles(@kristjan.task_list.all.first.contextual_list)
    assert_equal %w{1 2 3},
                 list_titles(@kristjan.task_list.all.last.contextual_list)
  end
  
  def test_move_to_bottom_of_project
    @blueprint.task_list.all.first.update_position(@blueprint.task_list.size)
    @blueprint.reload
    assert_equal %w{B C A}, titles(@blueprint)
    assert_equal %w{B C A 1 2 3}, titles(@kristjan)
  end

  def test_move_to_last_of_project_in_user_queue
    @kristjan.task_list.all.first.update_position(3)
    @kristjan.reload
    assert_equal %w{B C A 1 2 3}, titles(@kristjan)
    assert_equal %w{B C A}, titles(@blueprint)
  end

  def test_move_up_one_from_last_in_user_queue
    @blueprint.task_list.all.first.update_position(@blueprint.task_list.size)
    @kristjan.task_list[2].update_position(@blueprint.task_list.size-1)
    @blueprint.reload; @kristjan.reload
    assert_equal %w{B A C 1 2 3}, titles(@kristjan)
    assert_equal %w{B A C}, titles(@blueprint)
  end
end
