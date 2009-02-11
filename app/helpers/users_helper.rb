module UsersHelper
  def user_tabs(user)
    prioritized_count =
      user.task_list.size == 0 ? "" : " (#{user.task_list.size})"
    links = [
      ["PRIORITIZED#{prioritized_count}", user_path(user)],
      ["COMPLETED", completed_user_path(user)],
      ["PARKED", parked_user_path(user)]
    ]
    links.map do |name, url|
      class_name = current_page?(url) ? "current" : ""
      link_to name, url, :class => class_name
    end
  end  
end
