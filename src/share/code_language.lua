-- code_language.lua
-- Adds “language=” to {code} macros in Jira output.
-- Works with Pandoc's Jira writer.
-- Example:
--   ```python
--   print("hi")
--   ```
-- -> {code:language=python}...{code}

function CodeBlock(el)
  local lang = nil

  -- Pandoc provides the first class as a language, e.g. [“python”, “numberLines”]
  if el.classes and #el.classes > 0 then
    lang = el.classes[1]
  end

  -- If no language is specified: leave unchanged
  if not lang or lang == "" then
    return pandoc.RawBlock("jira",
      "{code}\n" .. el.text .. "\n{code}")
  end

  -- Language in lowercase letters (Confluence expects this)
  lang = string.lower(lang)

  -- Create Jira code block with language
  local code_block = "{code:language=" .. lang .. "}\n" .. el.text .. "\n{code}"
  return pandoc.RawBlock("jira", code_block)
end
