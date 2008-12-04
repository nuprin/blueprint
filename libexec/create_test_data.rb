User.destroy_all
Project.destroy_all
Task.destroy_all
TaskListItem.destroy_all

u1 = User.create! :name => "Brad"
u2 = User.create! :name => "Kristján"
p1 = Project.create! :title => "Petitions",
                     :description => %(A feature that lets people sign their
                     name on various petitions that nonprofits will deliver to
                     individuals or organizations in a position to effect
                     change.).squish

task_opts = {
  :kind => 'task',
  :status => 'assigned',
  :project => p1,
  :creator => u1,
  :assignee => u2
}

tasks = []
tasks << Task.create!(task_opts.merge(
  :title => "Add link tracking to announcements", :estimate => 3,
  :due_date => Date.today + rand(90)))
tasks << Task.create!(task_opts.merge(
  :title => "Display feature stats at top of stats page", :estimate => 10,
  :due_date => Date.today + rand(90)))
tasks << Task.create!(task_opts.merge(
  :title => "Allow site admins to remove petitions from causes",
  :estimate => 1, :due_date => Date.today + rand(90)))

task_opts[:creator], task_opts[:assignee] =
task_opts[:assignee], task_opts[:creator]

tasks << Task.create!(task_opts.merge(
  :title => "Implement 'Email All Signers' functionality",
  :due_date => Date.today + rand(90)))
tasks << Task.create!(task_opts.merge(
  :title => "Track status messages with Uhura", :estimate => 5,
  :due_date => Date.today + rand(90)))
