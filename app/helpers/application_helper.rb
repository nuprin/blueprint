# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_to_user(user)
    link_to user.name, user_path(user)
  end
  def link_to_project(project)
    link_to project.title, project_path(project)
  end
  def format_text(text)
    text = nl2br(text)
    auto_link(text, :all, :target => "_blank")
  end
  def nl2br(text)
    text.gsub(/\r\n?/, "\n").gsub(/\n/, '<br />')
  end
end
