module SearchesHelper
  # The mod 6 is because there are only 6 highlight classes in the CSS
  def highlight_query(str)
    highlighted = str.dup
    q = params[:q] || ''
    return if q.blank?
    q.split.each_with_index do |sub_q, i|
      next if sub_q.blank?
      highlighted.gsub!(/(\W)?(#{sub_q})(\W)?/i) do
        "#{$1}<span class='search_highlight_#{i % 6}'>#{$2}</span>#{$3}"
      end
    end
    highlighted
  end
end
