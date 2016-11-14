-- it's not written from scratch

module(..., package.seeall)

function dumpdata:dump(data, deep, multiline_style)
  local INDENT_STR = "    "

  if (type(data) ~= "table") then
    return tostring(data)
  end

  local dump_table

  if (not multiline_style) then
    dump_table = function(t, deep)
      local str = "{"

      if (deep) then
        for k, v in pairs(t) do
          if (type(v) == "table") then
            str = string.format("%s%s = %s, ",
                                str, tostring(k), dump_table(v, true))
          elseif (type(v) == "string") then
            str = string.format("%s%s = %q, ", str, tostring(k), v)
          else
            str = string.format("%s%s = %s, ", str, tostring(k), tostring(v))
          end
        end
      else
        for k, v in pairs(t) do
          if (type(v) == "string") then
            str = string.format("%s%s = %q, ", str, tostring(k), v)
          else
            str = string.format("%s%s = %s, ", str, tostring(k), tostring(v))
          end
        end
      end

      str = str .. "}"

      return str
    end
  else
    dump_table = function(t, deep, indent)
      local str = "{\n"

      if (deep) then
        for k, v in pairs(t) do
          if (type(v) == "table") then
            str = string.format("%s%s%s%s = %s,\n",
              str, indent, INDENT_STR, tostring(k),
              dump_table(v, true, indent .. INDENT_STR))
          elseif (type(v) == "string") then
            str = string.format("%s%s%s%s = %q,\n",
                                str, indent, INDENT_STR, tostring(k), v)
          else
            str = string.format("%s%s%s%s = %s,\n",
                                str, indent, INDENT_STR, tostring(k), tostring(v))
          end
        end
      else
        for k, v in pairs(t) do
          if (type(v) == "string") then
            str = string.format("%s%s%s%s = %q,\n",
                                str, indent, INDENT_STR, tostring(k), v)
          else
            str = string.format("%s%s%s%s = %s,\n",
                                str, indent, INDENT_STR, tostring(k), tostring(v))
          end
        end
      end

      str = str .. indent .. "}"

      return str
    end
  end

  return dump_table(data, deep, "")
end

