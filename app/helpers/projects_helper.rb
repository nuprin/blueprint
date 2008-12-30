module ProjectsHelper
  def project_fields(project)
    fields = []
    if project.due_date
      fields << ["DUE DATE", @project.due_date.strftime("%b %e")]
    else
      fields << ["ONGOING"]
    end
    if project.estimate > 0
      fields << ["ESTIMATE", pluralize(project.estimate, "hour")]
    end
    if project.assignees.any?
      assignees = project.assignees.map do |u|
        link_to_user u
      end.join(", ")
      fields << ["INVOLVED", assignees]
    end
    fields.map do |field|
      field.join(": ")
    end.join("<span class='divider'>|</span>")
  end
end
