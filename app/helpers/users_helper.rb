module UsersHelper
  def user_tabs(user)
    links = [
      ["PRIORITIZED (#{user.task_list.size})", user_path(user)],
      ["CARELOG", completed_user_path(user)],
      ["PARKED", parked_user_path(user)]
    ]
    links.map do |name, url|
      class_name = current_page?(url) ? "current" : ""
      link_to name, url, :class => class_name
    end
  end  
end
