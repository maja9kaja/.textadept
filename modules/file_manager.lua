local M = {}

local lfs = require('lfs')

local function list_directory(path)
  local items = {}
  for entry in lfs.dir(path) do
    if entry ~= "." and entry ~= ".." then
      local full_path = path .. '/' .. entry
      local attr = lfs.attributes(full_path)
      if attr then
        table.insert(items, {name = entry, path = full_path, mode = attr.mode})
      end
    end
  end
  table.sort(items, function(a, b)
    if a.mode == b.mode then
      return a.name:lower() < b.name:lower()
    else
      return a.mode == "directory"
    end
  end)
  return items
end

function M.show_file_manager(path)
  path = path or lfs.currentdir()
  local buf = buffer.new()
  buf._type = 'file_manager'
  buf._base_path = path
  buf:append_text("File Manager: " .. path .. "\n\n")
  local items = list_directory(path)
  for _, item in ipairs(items) do
    local display_name = item.name
    if item.mode == "directory" then
      display_name = display_name .. "/"
    end
    buf:append_text(display_name .. "\n")
  end
  buf.read_only = true
  buf:set_save_point()
  buf:goto_pos(buf:position_from_line(3))
end

local function file_manager_key_handler(code)
  if code == '\n' and buffer._type == 'file_manager' then
    local line_num = buffer:line_from_position(buffer.current_pos)
    local line_text = buffer:get_line(line_num):match("^%s*(.-)%s*$")
    if line_text == "" then return true end
    local full_path = buffer._base_path .. '/' .. line_text
    if line_text:sub(-1) == "/" then
      full_path = full_path:sub(1, -2)
    end
    local attr = lfs.attributes(full_path)
    if attr then
      if attr.mode == "directory" then
        M.show_file_manager(full_path)
      else
        io.open_file(full_path)
      end
    end
    return true
  end
end

events.connect(events.KEYPRESS, file_manager_key_handler)



local m_file = textadept.menu.menubar[_L['Tools']]
table.insert(m_file, #m_file - 1, {''})
table.insert(m_file, #m_file - 1, {
	'File manager', function()
    M.show_file_manager("/home/maja/")
	end
})

return M
