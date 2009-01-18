module ProjectsHelper
  def project_fields(project)
    fields = []
    if project.due_date
      fields << ["DUE DATE", @project.due_date.strftime("%b %e")]
    else
      fields << ["ONGOING"]
    end
    if project.category_id
      fields << ["CATEGORY", project.category.name]
    end
    if project.subscribed_users.any?
      assignees = project.subscribed_users.map do |u|
        link_to_user u
      end.join(", ")
      fields << ["FOLLOWING", assignees]
    end
    fields.map do |field|
      field.join(": ")
    end.join("<span class='divider'>|</span>")
  end
end
