local opt = vim.opt_local

-- Display long paragraphs across screen lines without modifying the file.
opt.wrap = true
opt.linebreak = true
opt.breakindent = true

-- Never insert hard line breaks automatically.
opt.textwidth = 0
opt.wrapmargin = 0

for _, flag in ipairs({ "a", "c", "t" }) do
  opt.formatoptions:remove(flag)
end

for _, flag in ipairs({ "j", "n", "q" }) do
  opt.formatoptions:append(flag)
end

-- Markdown prose checking.
opt.spell = true
opt.spelllang = { "en_us" }

-- Conceal markup outside the cursor line.
opt.conceallevel = 2
opt.concealcursor = ""

-- Markdown indentation.
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

-- Restore global defaults if this buffer changes filetype.
local undo = table.concat({
  "setlocal wrap<",
  "linebreak<",
  "breakindent<",
  "textwidth<",
  "wrapmargin<",
  "formatoptions<",
  "spell<",
  "spelllang<",
  "conceallevel<",
  "concealcursor<",
  "expandtab<",
  "tabstop<",
  "softtabstop<",
  "shiftwidth<",
}, " ")

if vim.b.undo_ftplugin then
  vim.b.undo_ftplugin = vim.b.undo_ftplugin .. " | " .. undo
else
  vim.b.undo_ftplugin = undo
end
