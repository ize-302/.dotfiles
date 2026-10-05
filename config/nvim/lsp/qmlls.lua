---@type vim.lsp.Config
return {
  -- System binary from qt6-declarative (a Quickshell dependency), not Mason.
  -- Quickshell fills in .qmlls.ini next to shell.qml so its modules resolve.
  cmd = { "qmlls6", "-E" },
  filetypes = { "qml", "qmljs" },
  root_markers = { ".qmlls.ini", "shell.qml", ".git" },
}
