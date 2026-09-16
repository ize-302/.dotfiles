vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

vim.g.colors_name = "zenin"

local palette = {
	bg = "#1a1b26",
	fg = "#c0caf5",

	black = "#15161e",
	red = "#f7768e",
	green = "#9ece6a",
	yellow = "#e0af68",
	blue = "#7aa2f7",
	magenta = "#bb9af7",
	cyan = "#7dcfff",
	white = "#a9b1d6",

	bright_black = "#414868",
	bright_red = "#f7768e",
	bright_green = "#9ece6a",
	bright_yellow = "#e0af68",
	bright_blue = "#7aa2f7",
	bright_magenta = "#bb9af7",
	bright_cyan = "#7dcfff",
	bright_white = "#c0caf5",
}

local set = vim.api.nvim_set_hl

-- Core UI
set(0, "Normal", { fg = palette.fg, bg = palette.bg })
set(0, "Cursor", { fg = palette.bg, bg = palette.fg })
set(0, "LineNr", { fg = palette.bright_black })
set(0, "CursorLineNr", { fg = palette.yellow })
set(0, "Visual", { bg = palette.bright_black })

-- Syntax
set(0, "Comment", { fg = palette.bright_black, italic = true })
set(0, "Keyword", { fg = palette.magenta })
set(0, "String", { fg = palette.green })
set(0, "Function", { fg = palette.blue })
set(0, "Identifier", { fg = palette.cyan })
set(0, "Type", { fg = palette.yellow })
set(0, "Constant", { fg = palette.red })

set(0, "Boolean", { link = "Constant" })
set(0, "Character", { link = "String" })
set(0, "Number", { link = "Constant" })

set(0, "StatusLine", {
	fg = palette.fg,
	bg = palette.black,
})

set(0, "StatusLineNC", {
	fg = palette.bright_black,
	bg = palette.bg,
})

set(0, "NvimTreeNormal", {
	bg = palette.black,
	fg = palette.white,
})

set(0, "NvimTreeFolderName", {
	fg = palette.blue,
})

set(0, "NvimTreeOpenedFolderName", {
	fg = palette.blue,
})

set(0, "NvimTreeFolderIcon", {
	fg = palette.blue,
})

set(0, "NvimTreeFileName", {
	fg = palette.fg,
})

set(0, "NvimTreeOpenedFile", {
	fg = palette.white,
	bold = true,
})

set(0, "NvimTreeExecFile", {
	fg = palette.green,
	bold = true,
})

set(0, "NvimTreeGitDirty", {
	fg = palette.yellow,
})

set(0, "NvimTreeGitStaged", {
	fg = palette.green,
})

set(0, "NvimTreeGitNew", {
	fg = palette.green,
})

set(0, "NvimTreeGitDeleted", {
	fg = palette.red,
})

set(0, "NvimTreeGitIgnored", {
	fg = palette.bright_black,
})
