module ProjectsHelper
  def project_fields(project)
    fields = []
    if project.due_date
      fields << ["DUE DATE", @project.due_date.strftime("%b %e")]
    else
      fields << ["ONGOING"]
    end
    if project.category_id
      fields << ["CATEGORY",
        link_to(project.category.name,
                projects_path(:category_id => project.category_id))]
    end
    if project.feature_id
      fields << ["FEATURE", project.feature.name]
    end
    if !project.phase.blank?
      fields << ["PHASE", project.phase]
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
    "PRODUCT & ENGINEERING", "ACTIVIST", "BUSINESS DEVELOPMENT"
  ]  
  def project_nav_links
    (ProjectCategory.all.map do |category|
      [category.name.upcase, projects_path(:category_id => category.id)]
    end).sort_by do |name, path| 
      TAB_ORDER.index(name) || 1000
    end
  end
  
  def link_to_project_spec(project, name = nil)
    name ||= "Spec"
    if project.external_spec?
      link_to name, project.cleaned_spec_url, :target => :blank
    else
      path = project_specification_path(project)
      if current_page?(path)
        link_to name, path, :class => "current"
      else
        link_to name, path
      end
    end
  end
end
