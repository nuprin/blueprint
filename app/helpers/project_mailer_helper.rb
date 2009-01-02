module ProjectMailerHelper
  def project_footer(project)
    fields = []
    if !project.subscribed_user_names.blank?
      fields << ["Subscribed", project.subscribed_user_names]
    end
    fields.map do |field|
      field.join(": ")
    end.join(" | ")
  end
end