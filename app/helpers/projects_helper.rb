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

  TAB_ORDER = [
    "PRODUCT", "ACTIVIST", "BUSINESS DEVELOPMENT", "ENGINEERING"
  ]
  def project_tab_links
    [["ALL", all_projects_path]] +
      (ProjectCategory.all.map do |category|
        [category.name.upcase, projects_path(:category_id => category.id)]
      end).sort_by do |name, path| 
        TAB_ORDER.index(name) || 1000
      end +
    [["UNCATEGORIZED", uncategorized_projects_path]]
  end
end
