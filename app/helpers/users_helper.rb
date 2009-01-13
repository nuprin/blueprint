module UsersHelper
  def user_tabs(user)
    links = [
      ["PRIORITIZED (#{user.task_list.size})", user_url(user)],
      ["COMPLETED", completed_user_url(user)],
      ["PARKED", parked_user_url(user)]
    ]
    links.map do |name, url|
      class_name = current_page?(url) ? "current" : ""
      link_to name, url, :class => class_name
    end
  end  
end
