
u1 = User.create! :name => "Brad"
u2 = User.create! :name => "Kristján"
p1 = Project.create! :title => "Petitions",
                     :description => %(A feature that lets people sign their
                     name on various petitions that nonprofits will deliver to
                     individuals or organizations in a position to effect
                     change.).squish

task_opts = {
  :type => 'task',
  :status => 'assigned',
  :project => p1,
  :creator => u1,
  :assignee => u2
}

tasks = []
tasks << Task.create! task_opts.merge(
  :title => "Add link tracking to announcements")
tasks << Task.create! task_opts.merge(
  :title => "Display feature stats at top of stats page")
tasks << Task.create! task_opts.merge(
  :title => "Allow site admins to remove petitions from causes")

task_opts[:creator],
task_opts[:assignee] = task_opts[:assignee],
                      task_opts[:creator]

tasks << Task.create! task_opts.merge(
  :title => "Implement 'Email All Signers' functionality")
tasks << Task.create! task_opts.merge(
  :title => "Track status messages with Uhura")

tasks.each_with_index do |task, ix|
  TaskListItem.create! :task_id => task.id, :context_id => p1.id,
                       :context_type => p1.class.name, :position => ix
end
