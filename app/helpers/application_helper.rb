# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper
  def link_to_user(user)
    link_to user.name, user_path(user)
  end
  def link_to_project(project)
    link_to project.title, project_path(project)
  end
  def link_to_task(task)
    link_to task.title, task_path(task)
  end
  # Order matters!  auto_link links things inside tags
  def format_text(text)
    text = nl2br(text)
    text = auto_link_tasks(text)
    auto_link(text, :all, :target => "_blank")
    text = auto_link_commits(text)
  end
  def auto_link_tasks(text)
    text.gsub /(?:^|\s)#(\d+)/ do |task|
      link_to task, task_path($1)
    end
  end
  def auto_link_commits(text)
    text.gsub /[a-f0-9]{6,40}/i do |hash|
      link_to hash, "http://git/causes/commit?id=#{hash}", :target => :blank
    end
  end
  def nl2br(text)
    text.gsub(/\r\n?/, "\n").gsub(/\n/, '<br />')
  end
  def if_any(collection)
    if collection.any?
      yield collection
    end
  end
  def with_layout(layout_name, locals = {}, &block)
    render_content = {
      :layout => layout_name, :text => capture(&block), :locals => locals
    }
    content = render(render_content)
    concat(content, block.binding)
  end
  def with_locals(locals, &block)
    with_options(:locals => locals, &block)
  end
end
