-- Map Markdown authoring levels to GB/T 9704-2012 official document styles.
--
-- Markdown users write:
--   #  公文标题
--   ## 一、正文第一层
--   ### （一）正文第二层
--   #### 1. 正文第三层
--   ##### （1）正文第四层

local function styled_div(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

function Header(header)
  if header.level == 1 then
    return styled_div({ pandoc.Para(header.content) }, "Title")
  end

  if header.level >= 2 and header.level <= 5 then
    header.level = header.level - 1
    return header
  end

  return header
end

function Para(para)
  return styled_div({ para }, "Body Text")
end
