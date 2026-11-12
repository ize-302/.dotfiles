vim.pack.add({ "https://github.com/folke/tokyonight.nvim" })

local ok, tokyonight = pcall(require, "tokyonight")
if not ok then
	return
end

tokyonight.setup({
	style = "night",
	transparent = false,
	terminal_colors = true,
	styles = {
		comments = { italic = false },
		keywords = { italic = false },
		sidebars = "dark",
		floats = "dark",
	},
	-- Match Zed's Tokyo Night (ssaunderss/zed-tokyo-night) syntax colors.
	on_highlights = function(hl)
		local zed = {
			["#a9b1d6"] = { "Normal" },
			["#51597d"] = { "Comment", "@comment", "@comment.documentation", "@tag.doctype" },
			["#bb9af7"] = {
				"@attribute", "@character.special", "@constant.macro", "@function.decorator",
				"@function.macro", "@keyword", "@keyword.conditional", "@keyword.conditional.ternary",
				"@keyword.coroutine", "@keyword.directive", "@keyword.directive.define",
				"@keyword.exception", "@keyword.export", "@keyword.function", "@keyword.import",
				"@keyword.modifier", "@keyword.repeat", "@keyword.return", "@keyword.type",
				"@string.escape", "@tag.attribute",
			},
			["#7aa2f7"] = {
				"@function", "@function.builtin", "@function.call", "@function.method",
				"@function.method.call",
			},
			["#c0caf5"] = {
				"@label", "@module", "@property", "@variable", "@variable.member",
				"@variable.parameter",
			},
			["#0db9d7"] = {
				"@type", "@type.builtin", "@type.class.definition", "@type.definition",
				"@type.interface", "@type.super",
			},
			["#89ddff"] = {
				"@keyword.operator", "@operator", "@punctuation", "@punctuation.bracket",
				"@punctuation.delimiter", "@punctuation.list_marker", "@punctuation.special",
				"@tag.delimiter",
			},
			["#9ece6a"] = {
				"@character", "@string", "@string.doc", "@string.documentation", "@string.regexp",
				"@string.special", "@string.special.path", "@string.special.symbol",
			},
			["#ff9e64"] = { "@boolean", "@constant", "@constant.builtin", "@number", "@number.float" },
			["#f7768e"] = {
				"@constructor", "@keyword.debug", "@tag", "@variable.builtin", "@variable.special",
			},
			["#7dcfff"] = { "@string.special.url" },
		}
		for color, groups in pairs(zed) do
			for _, group in ipairs(groups) do
				local spec = type(hl[group]) == "table" and vim.deepcopy(hl[group]) or {}
				spec.link = nil
				spec.fg = color
				hl[group] = spec
			end
		end
	end,
})

vim.cmd.colorscheme("tokyonight")
