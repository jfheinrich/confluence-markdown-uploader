-- panel.lua
-- Convert fenced Divs to Confluence/Jira panels.
-- Usage in MD: ::: {.info title="Hinweis"} ... :::
-- Classes supported: info, warning, success, tip, note
-- Fallback: first paragraph {title="..."} is treated as title if present.

local CLASS_TO_MACRO = {
  info    = "info",
  warning = "warning",
  success = "success",
  tip     = "tip",
  note    = "note",
}

local function has_class(el, cls)
  for _, c in ipairs(el.classes or {}) do
    if c == cls then return true end
  end
  return false
end

local function render_jira(blocks)
  local doc = pandoc.Pandoc(blocks, pandoc.Meta({}))
  return pandoc.write(doc, "jira")
end

local function extract_title_attr(el)
  if el.attributes then
    return el.attributes["title"] or el.attributes["data-title"]
  end
  return nil
end

-- Optional fallback: if first paragraph is exactly {title="..."} pull it out
local function extract_title_fallback_and_strip(blocks)
  if #blocks == 0 then return nil, blocks end
  local first = blocks[1]
  if first.t == "Para" and #first.c == 1 and first.c[1].t == "Str" then
    local s = first.c[1].text or ""
    local title = s:match("^%{title=\"(.-)\"%}$")
    if title then
      local rest = {}
      for i = 2, #blocks do table.insert(rest, blocks[i]) end
      return title, rest
    end
  end
  return nil, blocks
end

local function emit_panel(macro, title, blocks)
  local body = render_jira(blocks)
  if title and #title > 0 then
    title = tostring(title):gsub("}", "\\}")
    return pandoc.RawBlock("jira", "{"
      .. macro .. ":title=" .. title .. "}\n"
      .. body .. "\n{" .. macro .. "}")
  else
    return pandoc.RawBlock("jira", "{"
      .. macro .. "}\n"
      .. body .. "\n{" .. macro .. "}")
  end
end

function Div(el)
  -- find which macro to use
  local macro = nil
  for cls, m in pairs(CLASS_TO_MACRO) do
    if has_class(el, cls) then macro = m; break end
  end
  if not macro then
    -- also support "panel" with type attr: ::: {.panel type="info"}
    if has_class(el, "panel") and el.attributes and el.attributes["type"] then
      local t = el.attributes["type"]
      macro = CLASS_TO_MACRO[t]
    end
  end
  if not macro then return nil end

  local title = extract_title_attr(el)
  local content = el.content
  if not title then
    local t2, rest = extract_title_fallback_and_strip(content)
    if t2 then title = t2; content = rest end
  end
  return emit_panel(macro, title, content)
end
