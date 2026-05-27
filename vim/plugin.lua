require("noice").setup({
    views = {
        cmdline_popup = {
            position = {
                row = "20%",
                col = "50%",
            }
        },
        cmdline_popupmenu = {
            position = {
                -- Dynamically calculate: (20% of total editor lines) + 2 lines offset
                row = math.floor(vim.o.lines * 0.20) + 3,
                col = "50%",
            },
            size = {
                -- Dynamically fits the longest completion item
                width = "auto",
                -- Ensures enough space for completion details
                min_width = 30,
                height = 10,
            },
        },
    },
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

require('notify').setup({
    max_wdith = 80,
    render = "wrapped-compact",
    stages = "fade",
    timeout = 500,
})

require('bqf').setup({
  preview = {
    win_height = 30,
    win_vheight = 30,
  },
})
