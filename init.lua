-- Maja's ta config, some stuff come from orbitalquark's .textadept

if not CURSES then
	view:set_theme('zig', {font = 'GohuFont uni14 Nerd Font Propo', size = 9})
end

view.h_scroll_bar, view.v_scroll_bar = false, false
buffer.tab_width = 2
ui.find.highlight_all_matches = true

textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
textadept.editing.auto_enclose = true
local function set_strip_trailing_spaces()
	textadept.editing.strip_trailing_spaces = buffer.lexer_language ~= 'diff'
end

require('file_manager')

require('spellcheck')
require('file_diff')
require('lua_repl')

local lsp = require('lsp')
lsp.server_commands.cpp = 'clangd'
lsp.server_commands.zig = 'zls'

-- VCS diff of current file.
local m_file = textadept.menu.menubar[_L['File']]
table.insert(m_file, #m_file - 1, {''}) -- before Quit
table.insert(m_file, #m_file - 1, {
	'VCS Diff', function()
		local root = io.get_project_root()
		if not buffer.filename or not root then return end
		local diff
		if lfs.attributes(root .. '/.hg') then
			diff = os.spawn('hg diff "' .. buffer.filename .. '"', root):read('a')
		elseif lfs.attributes(root .. '/.git') then
			diff = os.spawn('git diff "' .. buffer.filename .. '"', root):read('a')
		else
			return
		end
		local buffer = buffer.new()
		buffer:set_lexer('diff')
		buffer:add_text(diff)
		buffer:goto_pos(1)
		buffer:set_save_point()
	end
})

textadept.run.build_commands['build.zig'] = '~/.local/bin/zig build'
textadept.run.run_commands['build.zig'] = '~/.local/bin/zig build run'
