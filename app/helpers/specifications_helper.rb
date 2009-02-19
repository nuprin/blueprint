module SpecificationsHelper
  def highlight_rfcs(text)
    text.gsub(/(RFC:.*?\?)/) do
      "<span class='rfc'>#{$1}</span>"
    end
  end
end
