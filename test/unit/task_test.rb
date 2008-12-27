require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  test "A task requires a title and creator" do
    @task = Task.new(:title => "This is a test", :creator_id => users(:one).id)
    assert @task.valid?
  end
end
