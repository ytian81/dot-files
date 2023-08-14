require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = false, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})

-- require('notify').setup({
--     timeout = 500,
-- })

require('fm-nvim').setup{
  ui = {
    float = {
        border    = "rounded",
        float_hl  = "Normal",
        border_hl = "Comment",
        blend     = 10,

        width     = vim.api.nvim_win_get_width(0) > 240 and 0.8 or 0.9,
        height    = 0.65,
        x         = 0.5,
        y         = 0.5,
      }
  },
}

require('mini.splitjoin').setup()
