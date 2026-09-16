---@type vim.lsp.Config
return {
  root_markers = { ".git", ".obsidian", ".moxide.toml" },
  filetypes = { "markdown" },
  cmd = { "markdown-oxide" },
  on_attach = function(client, bufnr)
    for _, cmd in ipairs({ "today", "tomorrow", "yesterday" }) do
      vim.api.nvim_buf_create_user_command(
        bufnr,
        "Lsp" .. cmd:gsub("^%l", string.upper),
        function()
          client:exec_cmd({
            title = ("Markdown-Oxide-%s"):format(cmd),
            command = "jump",
            arguments = { cmd },
          }, { bufnr = bufnr })
        end,
        { desc = ("Open %s daily note"):format(cmd) }
      )
    end
  end,
}
