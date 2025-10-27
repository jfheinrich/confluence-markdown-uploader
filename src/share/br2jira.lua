-- br2jira.lua
-- Force line breaks for Jira Writer:
-- 1) Markdown HardBreak (two spaces or backslash at the end of the line) -> “\\”
-- 2) Raw HTML <br> / <br/> -> “\\”

-- Markdown hard breaks are represented as line break nodes in Pandoc.
function LineBreak(el)
  return pandoc.RawInline("jira", "\\\\")
end

-- Explicit <br> tags in the source
function RawInline(el)
  if el.format == "html" then
    local t = el.text
    if t:match("^%s*<br%s*/?>%s*$") then
      return pandoc.RawInline("jira", "\\\\")
    end
  end
  return nil
end
