module ExtractionsHelper
  # Wraps occurrences of +value+ in +source_text+ with a <mark> tag.
  # Both strings are HTML-escaped before substitution to prevent XSS.
  def highlight_extraction(source_text, value)
    escaped = h(source_text)
    return escaped if value.blank?

    pattern = Regexp.new(Regexp.escape(h(value)), Regexp::IGNORECASE)
    escaped.gsub(pattern) { |match| "<mark class=\"bg-yellow-200 rounded-sm px-0.5\">#{match}</mark>" }.html_safe
  end
end
