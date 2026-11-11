-- lstviz : dit a lstviz sur quelle ligne est ton curseur, pour que le schema
-- saute a l'etat de la memoire a cette ligne.
--
-- Installation : copie ce fichier dans ~/.config/nvim/plugin/lstviz.lua
-- (nvim charge tout seul les fichiers de plugin/ au demarrage).
--
-- Ne fait rien tant que lstviz n'est pas lance. :LstvizToggle pour couper.

if vim.g.loaded_lstviz then
	return
end
vim.g.loaded_lstviz = true

local uv = vim.uv or vim.loop
local user = os.getenv("LOGNAME") or os.getenv("USER")
if not user and uv.os_get_passwd then
	user = uv.os_get_passwd().username
end
user = user or "user"
local dir = "/tmp/lstviz-" .. user
local active = dir .. "/active"
local cursor = dir .. "/cursor.json"
local timer = uv.new_timer()
local last = ""

local function send()
	if vim.g.lstviz_disable or not uv.fs_stat(active) then
		return
	end
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" or not file:match("%.[ch]$") then
		return
	end
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local msg = vim.fn.json_encode({ file = file, line = line })
	if msg == last then
		return
	end
	last = msg
	pcall(vim.fn.writefile, { msg }, cursor)
end

local function later()
	timer:stop()
	timer:start(80, 0, vim.schedule_wrap(send))
end

local group = vim.api.nvim_create_augroup("lstviz", { clear = true })
vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter" }, { group = group, callback = later })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	callback = function()
		last = ""
		later()
	end,
})

vim.api.nvim_create_user_command("LstvizToggle", function()
	vim.g.lstviz_disable = not vim.g.lstviz_disable
	print("lstviz : suivi du curseur " .. (vim.g.lstviz_disable and "coupé" or "actif"))
end, {})
