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

-- Disable built-in ftplugin buffer-local mappings (]], [[, ]m, [m, etc.)
-- so nvim-treesitter-textobjects mappings are never shadowed.
vim.g.no_plugin_maps = true

-- Treesitter parsers and queries to ensure installed (replaces vim-polyglot)
local ensure_installed = {
  "bash",
  "c",
  "cmake",
  "comment",
  "cpp",
  "css",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
  "zsh",
}

-- Only load nvim-treesitter.install when at least one parser .so or query dir is missing
local site_dir = vim.fn.stdpath("data") .. "/site"
local parser_dir = site_dir .. "/parser"
local query_dir = site_dir .. "/queries"
local missing_parsers = false
for _, lang in ipairs(ensure_installed) do
  if not vim.uv.fs_stat(parser_dir .. "/" .. lang .. ".so")
    or not vim.uv.fs_stat(query_dir .. "/" .. lang)
  then
    missing_parsers = true
    break
  end
end
if missing_parsers then
  require("nvim-treesitter").install(ensure_installed)
end

-- Neovim 0.12 #offset! sets metadata[id].offset instead of metadata[id].range,
-- whereas nvim-treesitter-textobjects reads metadata[id].range. Populate both
-- so offset-adjusted textobjects (e.g. @conditional.inner, @comment.inner) work.
vim.treesitter.query.add_directive("offset!", function(match, _, bufnr, pred, metadata)
  local capture_id = pred[2]
  local nodes = match[capture_id]
  if not nodes or #nodes == 0 then
    return
  end
  metadata[capture_id] = metadata[capture_id] or {}
  metadata[capture_id].offset = {
    tonumber(pred[3]) or 0,
    tonumber(pred[4]) or 0,
    tonumber(pred[5]) or 0,
    tonumber(pred[6]) or 0,
  }
  if #nodes == 1 and type(bufnr) == "number" then
    metadata[capture_id].range =
      vim.treesitter.get_range(nodes[1], bufnr, metadata[capture_id])
  end
end, { force = true, all = true })

-- Strip leading/trailing comment markers (//, /* */, #, ") for @comment.inner
-- in languages whose upstream textobjects.scm only defines @comment.outer.
vim.treesitter.query.add_directive("comment-inner!", function(match, _, bufnr, pred, metadata)
  local capture_id = pred[2]
  local nodes = match[capture_id]
  if not nodes or #nodes == 0 or type(bufnr) ~= "number" then
    return
  end
  local srow, scol, erow, ecol = nodes[1]:range()
  if ecol == 0 and erow > srow then
    erow = erow - 1
    ecol = #(vim.api.nvim_buf_get_lines(bufnr, erow, erow + 1, false)[1] or "")
  end
  local first_line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1] or ""
  local first_end = (srow == erow) and ecol or #first_line
  local first_slice = first_line:sub(scol + 1, first_end)
  local is_block = first_slice:match("^/%*+") ~= nil

  if is_block then
    if srow < erow and first_slice:match("^/%*+[ \t]*$") then
      srow = srow + 1
      scol = 0
    else
      local p = first_slice:match("^(/%*+[ \t]?)") or ""
      scol = scol + #p
    end
    local last_line = vim.api.nvim_buf_get_lines(bufnr, erow, erow + 1, false)[1] or ""
    local last_start = (srow == erow) and scol or 0
    local last_slice = last_line:sub(last_start + 1, ecol)
    if erow > srow and last_slice:match("^[ \t]*%*+/$") then
      erow = erow - 1
      ecol = #(vim.api.nvim_buf_get_lines(bufnr, erow, erow + 1, false)[1] or "")
    else
      local s = last_slice:match("([ \t]?%*+/)$") or ""
      if #last_slice - #s == 0 and first_slice:match("^/%*+[ \t]") then
        scol = scol - 1
      end
      ecol = ecol - #s
    end
  else
    local p = first_slice:match("^(//+[ \t]?)")
      or first_slice:match("^(#+[ \t]?)")
      or first_slice:match('^("+[ \t]?)')
      or ""
    scol = scol + #p
  end

  if srow == erow and scol > ecol then
    scol = ecol
  end
  metadata[capture_id] = metadata[capture_id] or {}
  metadata[capture_id].range = { srow, scol, erow, ecol }
end, { force = true, all = true })

local comment_inner_rule = [[; extends
((comment) @comment.inner (#comment-inner! @comment.inner))
]]

local c_textobjects_ext = comment_inner_rule .. [[
(compound_statement
  .
  "{"
  _+ @block.inner
  "}")
]]

for _, lang in ipairs({ "c", "cpp" }) do
  vim.treesitter.query.set(lang, "textobjects", c_textobjects_ext)
end
for _, lang in ipairs({
  "bash",
  "go",
  "javascript",
  "json",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "zsh",
}) do
  vim.treesitter.query.set(lang, "textobjects", comment_inner_rule)
end

-- True while some window is in diff mode or still owes a fold restore, so
-- the SafeState hook in the diff section below stays cheap otherwise.
local diff_tracking = false

local function has_treesitter_folds(buf)
  if not vim.api.nvim_buf_is_valid(buf)
    or not vim.treesitter.highlighter.active[buf]
  then
    return false
  end
  local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  return lang ~= nil and vim.treesitter.query.get(lang, "folds") ~= nil
end

-- Leave diff windows alone: diff mode owns folding (foldmethod=diff).
-- Remember them so treesitter folds apply once diff mode ends.
local function set_treesitter_fold(win)
  if vim.wo[win].diff then
    vim.w[win].ts_fold_pending = true
    diff_tracking = true
    return
  end
  vim.w[win].ts_fold_pending = nil
  vim.wo[win].foldmethod = "expr"
  vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
end

local function attach_treesitter(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if pcall(vim.treesitter.start, buf, lang) then
    if vim.treesitter.query.get(lang, "folds") then
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        set_treesitter_fold(win)
      end
    end
    if vim.treesitter.query.get(lang, "indents") then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function(args)
    if has_treesitter_folds(args.buf) then
      set_treesitter_fold(vim.api.nvim_get_current_win())
    end
  end,
})

local installing_parsers = {}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang or lang == "" then
      return
    end

    if vim.treesitter.language.add(lang) then
      vim.schedule(function()
        attach_treesitter(args.buf, lang)
      end)
      return
    end

    -- Auto-install any supported nvim-treesitter parser on demand
    local parser_cfg = require("nvim-treesitter.parsers")[lang]
    if parser_cfg
      and parser_cfg.install_info
      and parser_cfg.tier ~= 4
      and not installing_parsers[lang]
    then
      installing_parsers[lang] = true
      vim.notify(string.format("Installing Treesitter parser for %s...", lang))
      require("nvim-treesitter").install(lang):await(function()
        installing_parsers[lang] = nil
        vim.schedule(function()
          if vim.treesitter.language.add(lang) then
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf)
                and vim.treesitter.language.get_lang(vim.bo[buf].filetype) == lang
              then
                attach_treesitter(buf, lang)
              end
            end
          end
        end)
      end)
    end
  end,
})

local ts_config = require("nvim-treesitter-textobjects.config")
local ts_select = require("nvim-treesitter-textobjects.select")
local ts_shared = require("nvim-treesitter-textobjects.shared")
local ts_swap = require("nvim-treesitter-textobjects.swap")
local ts_move = require("nvim-treesitter-textobjects.move")
local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
local ts_core_select = require("vim.treesitter._select")

local linewise_captures = {
  ["@function.outer"] = true,
  ["@function.inner"] = true,
  ["@class.outer"] = true,
  ["@class.inner"] = true,
  ["@loop.outer"] = true,
  ["@loop.inner"] = true,
  ["@conditional.outer"] = true,
  ["@conditional.inner"] = true,
  ["@block.outer"] = true,
  ["@block.inner"] = true,
  ["@comment.outer"] = true,
  ["@statement.outer"] = true,
}

local active_target_range = nil

local function range_end_row(r)
  return (r[5] == 0 and r[4] > r[1]) and (r[4] - 1) or r[4]
end

local function is_full_line_range(bufnr, r)
  if not r then
    return false
  end
  local srow, scol, erow, ecol = r[1], r[2], r[4], r[5]
  local start_line =
    vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1] or ""
  if not start_line:sub(1, scol):match("^%s*$") then
    return false
  end
  if ecol == 0 and erow > srow then
    return true
  end
  local end_line =
    vim.api.nvim_buf_get_lines(bufnr, erow, erow + 1, false)[1] or ""
  return end_line:sub(ecol + 1):match("^%s*$") ~= nil
end

require("nvim-treesitter-textobjects").setup({
  select = {
    -- Automatically jump forward to textobj, similar to targets.vim
    lookahead = true,
    lookbehind = true,
    selection_modes = function(opts)
      if linewise_captures[opts.query_string]
        and is_full_line_range(vim.api.nvim_get_current_buf(), active_target_range)
      then
        return "V"
      end
      return "v"
    end,
    include_surrounding_whitespace = function(opts)
      return opts.query_string == "@parameter.outer"
    end,
  },
  move = {
    set_jumps = true,
  },
})

-- Seek in targets.vim priority order:
-- 1. enclosing or ahead on current line
-- 2. behind on current line
-- 3. ahead on following lines
-- 4. behind on preceding lines
local function select_textobject(query, group)
  group = group or "textobjects"
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local fwd =
    ts_shared.textobject_at_point(query, group, bufnr, nil, { lookahead = true })
  if fwd and fwd[1] <= row then
    active_target_range = fwd
    ts_select.select_textobject(query, group)
    active_target_range = nil
    return
  end
  local bwd =
    ts_shared.textobject_at_point(query, group, bufnr, nil, { lookbehind = true })
  if (bwd and range_end_row(bwd) >= row) or not fwd then
    active_target_range = bwd
    ts_config.update({ select = { lookahead = false, lookbehind = true } })
    ts_select.select_textobject(query, group)
    ts_config.update({ select = { lookahead = true, lookbehind = true } })
    active_target_range = nil
    return
  end
  active_target_range = fwd
  ts_select.select_textobject(query, group)
  active_target_range = nil
end

-- Fix Neovim 0.12's built-in incremental AST selection (an, in, ]n, [n)
-- under `set selection=exclusive`, where visual_select/get_selection assume
-- inclusive `'>` endpoints and otherwise drop the last character of each node.
local function dec_pos(p)
  if p[3] > 1 then
    local line = vim.fn.getline(p[2])
    local char_idx = vim.fn.charidx(line, p[3] - 1)
    local prev_byte = vim.fn.byteidx(line, char_idx - 1)
    p[3] = (prev_byte >= 0) and (prev_byte + 1) or (p[3] - 1)
  elseif p[2] > 1 then
    p[2] = p[2] - 1
    p[3] = #vim.fn.getline(p[2]) + 1
  end
end

local function inc_pos(p)
  local line = vim.fn.getline(p[2])
  if p[3] <= #line then
    local char_idx = vim.fn.charidx(line, p[3] - 1)
    local next_byte = vim.fn.byteidx(line, char_idx + 1)
    p[3] = (next_byte >= 0) and (next_byte + 1) or (#line + 1)
  end
end

local function wrap_core_ts_select(fn)
  return function(...)
    if vim.o.selection ~= "exclusive" then
      return fn(...)
    end
    if vim.fn.mode() == "v" then
      local vpos = vim.fn.getpos("v")
      local cpos = vim.fn.getpos(".")
      if vpos[2] < cpos[2] or (vpos[2] == cpos[2] and vpos[3] < cpos[3]) then
        dec_pos(cpos)
        vim.fn.setpos(".", cpos)
      elseif vpos[2] > cpos[2] or (vpos[2] == cpos[2] and vpos[3] > cpos[3]) then
        vim.cmd.normal({ "o", bang = true })
        vpos = vim.fn.getpos(".")
        dec_pos(vpos)
        vim.fn.setpos(".", vpos)
        vim.cmd.normal({ "o", bang = true })
      end
    end
    fn(...)
    if vim.fn.mode() == "v" then
      local vpos = vim.fn.getpos("v")
      local cpos = vim.fn.getpos(".")
      if vpos[2] < cpos[2] or (vpos[2] == cpos[2] and vpos[3] <= cpos[3]) then
        inc_pos(cpos)
        vim.fn.setpos(".", cpos)
      else
        vim.cmd.normal({ "o", bang = true })
        vpos = vim.fn.getpos(".")
        inc_pos(vpos)
        vim.fn.setpos(".", vpos)
        vim.cmd.normal({ "o", bang = true })
      end
    end
  end
end

vim.keymap.set({ "x", "o" }, "an", wrap_core_ts_select(function()
  ts_core_select.select_parent(vim.v.count1)
end), { desc = "Select parent AST node" })
vim.keymap.set({ "x", "o" }, "in", wrap_core_ts_select(function()
  ts_core_select.select_child(vim.v.count1)
end), { desc = "Select child AST node" })
vim.keymap.set("x", "]n", wrap_core_ts_select(function()
  ts_core_select.select_next(vim.v.count1)
end), { desc = "Select next sibling AST node" })
vim.keymap.set("x", "[n", wrap_core_ts_select(function()
  ts_core_select.select_prev(vim.v.count1)
end), { desc = "Select prev sibling AST node" })

-- Textobject selection (replaces targets.vim / coc-funcobj)
local select_maps = {
  { "aa", "@parameter.outer", "textobjects", "Select outer parameter" },
  { "ia", "@parameter.inner", "textobjects", "Select inner parameter" },
  { "ai", "@conditional.outer", "textobjects", "Select outer conditional" },
  { "ii", "@conditional.inner", "textobjects", "Select inner conditional" },
  { "al", "@loop.outer", "textobjects", "Select outer loop" },
  { "il", "@loop.inner", "textobjects", "Select inner loop" },
  { "am", "@function.outer", "textobjects", "Select outer method/function" },
  { "im", "@function.inner", "textobjects", "Select inner method/function" },
  { "af", "@function.outer", "textobjects", "Select outer function" },
  { "if", "@function.inner", "textobjects", "Select inner function" },
  { "aF", "@call.outer", "textobjects", "Select outer call" },
  { "iF", "@call.inner", "textobjects", "Select inner call" },
  { "ac", "@class.outer", "textobjects", "Select outer class" },
  { "ic", "@class.inner", "textobjects", "Select inner class" },
  { "ak", "@block.outer", "textobjects", "Select outer block" },
  { "ik", "@block.inner", "textobjects", "Select inner block" },
  { "a/", "@comment.outer", "textobjects", "Select outer comment" },
  { "i/", "@comment.inner", "textobjects", "Select inner comment" },
  { "a=", "@assignment.outer", "textobjects", "Select outer assignment" },
  { "i=", "@assignment.inner", "textobjects", "Select inner assignment" },
  { "l=", "@assignment.lhs", "textobjects", "Select assignment LHS" },
  { "r=", "@assignment.rhs", "textobjects", "Select assignment RHS" },
  { "ar", "@return.outer", "textobjects", "Select outer return" },
  { "ir", "@return.inner", "textobjects", "Select inner return" },
  { "a;", "@statement.outer", "textobjects", "Select outer statement" },
  { "i#", "@number.inner", "textobjects", "Select inner number" },
  { "as", "@local.scope", "locals", "Select local scope" },
}
for _, map in ipairs(select_maps) do
  vim.keymap.set({ "x", "o" }, map[1], function()
    select_textobject(map[2], map[3])
  end, { desc = map[4] })
end

-- AST node swapping (replaces machakann/vim-swap)
local swap_targets = { "@parameter.inner", "@function.outer" }
vim.keymap.set("n", "g>", function()
  ts_swap.swap_next(swap_targets)
end, { desc = "Swap with next parameter or function" })
vim.keymap.set("n", "g<", function()
  ts_swap.swap_previous(swap_targets)
end, { desc = "Swap with prev parameter or function" })

local function is_capture_end_at_cursor(query_strings, query_group)
  if not query_strings then
    return false
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1] - 1, cur[2]
  query_group = query_group or "textobjects"
  if type(query_strings) == "string" then
    query_strings = { query_strings }
  end
  local matched_end = false
  for _, qs in ipairs(query_strings) do
    local has_start = ts_shared.find_best_range(bufnr, qs, query_group, function(r)
      return r[1] == row and r[2] == col
    end, function()
      return 0
    end)
    if has_start then
      return false
    end
    local has_end = ts_shared.find_best_range(bufnr, qs, query_group, function(r)
      local erow, ecol = r[4], r[5]
      if ecol == 0 then
        erow = erow - 1
        ecol = #vim.api.nvim_buf_get_lines(bufnr, erow, erow + 1, true)[1]
      else
        ecol = ecol - 1
      end
      return erow == row and ecol == col
    end, function()
      return 0
    end)
    if has_end then
      matched_end = true
    end
  end
  return matched_end
end

-- Adjust operator-pending end motions (e.g. d]M, d][, d]i at conditional end)
-- under selection=exclusive so the closing delimiter is included rather than
-- excluded by charwise `v`.
local function fix_exclusive_op_end(was_op, is_end)
  if not (was_op and vim.o.selection == "exclusive" and vim.fn.mode() == "v") then
    return
  end
  if is_end == nil and ts_repeat_move.last_move then
    local args = ts_repeat_move.last_move.additional_args or {}
    is_end = is_capture_end_at_cursor(args[1], args[2])
  end
  if is_end then
    local vpos = vim.fn.getpos("v")
    local cpos = vim.fn.getpos(".")
    if vpos[2] < cpos[2] or (vpos[2] == cpos[2] and vpos[3] <= cpos[3]) then
      inc_pos(cpos)
      vim.fn.setpos(".", cpos)
    end
  end
end

-- Textobject navigation
local move_maps = {
  { "]m", "goto_next_start", "@function.outer", "textobjects", "Next function start" },
  { "]M", "goto_next_end", "@function.outer", "textobjects", "Next function end" },
  { "[m", "goto_previous_start", "@function.outer", "textobjects", "Prev function start" },
  { "[M", "goto_previous_end", "@function.outer", "textobjects", "Prev function end" },
  { "]]", "goto_next_start", "@class.outer", "textobjects", "Next class start" },
  { "][", "goto_next_end", "@class.outer", "textobjects", "Next class end" },
  { "[[", "goto_previous_start", "@class.outer", "textobjects", "Prev class start" },
  { "[]", "goto_previous_end", "@class.outer", "textobjects", "Prev class end" },
  { "],", "goto_next_start", "@parameter.inner", "textobjects", "Next parameter" },
  { "[,", "goto_previous_start", "@parameter.inner", "textobjects", "Prev parameter" },
  { "]i", "goto_next", "@conditional.outer", "textobjects", "Next conditional" },
  { "[i", "goto_previous", "@conditional.outer", "textobjects", "Prev conditional" },
  { "]O", "goto_next_start", "@loop.outer", "textobjects", "Next loop" },
  { "[O", "goto_previous_start", "@loop.outer", "textobjects", "Prev loop" },
  { "]F", "goto_next_start", "@call.outer", "textobjects", "Next call" },
  { "[F", "goto_previous_start", "@call.outer", "textobjects", "Prev call" },
  { "]r", "goto_next_start", "@return.outer", "textobjects", "Next return" },
  { "[r", "goto_previous_start", "@return.outer", "textobjects", "Prev return" },
  { "]/", "goto_next_start", "@comment.outer", "textobjects", "Next comment" },
  { "[/", "goto_previous_start", "@comment.outer", "textobjects", "Prev comment" },
  { "]s", "goto_next_start", "@local.scope", "locals", "Next local scope" },
  { "[s", "goto_previous_start", "@local.scope", "locals", "Prev local scope" },
  { "]z", "goto_next_start", "@fold", "folds", "Next fold" },
  { "[z", "goto_previous_start", "@fold", "folds", "Prev fold" },
}
for _, map in ipairs(move_maps) do
  local is_end = nil
  if map[2]:find("_end$") then
    is_end = true
  elseif map[2]:find("_start$") then
    is_end = false
  end
  vim.keymap.set({ "n", "x", "o" }, map[1], function()
    local was_op = vim.api.nvim_get_mode().mode == "no"
    ts_move[map[2]](map[3], map[4])
    fix_exclusive_op_end(was_op, is_end)
  end, { desc = map[5] })
end

-- Repeatable AST motions with ; and , (cooperating with vim-sneak and f/F/t/T)
vim.api.nvim_create_autocmd("User", {
  pattern = "SneakEnter",
  callback = function()
    ts_repeat_move.last_move = nil
  end,
})

local function repeat_move(opposite)
  if ts_repeat_move.last_move then
    local was_op = vim.api.nvim_get_mode().mode == "no"
    local start_opt = ts_repeat_move.last_move.opts
      and ts_repeat_move.last_move.opts.start
    local is_end = nil
    if start_opt ~= nil then
      is_end = not start_opt
    end
    if opposite then
      ts_repeat_move.repeat_last_move_opposite()
    else
      ts_repeat_move.repeat_last_move()
    end
    fix_exclusive_op_end(was_op, is_end)
    return
  end
  local mode = vim.api.nvim_get_mode().mode
  local op = ""
  if mode:sub(1, 2) == "no" then
    op = vim.v.operator
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! " .. vim.v.count1 .. "\27")
    op = vim.fn.visualmode()
  end
  vim.fn["sneak#rpt"](op, opposite and 1 or 0)
end

vim.keymap.set({ "n", "x", "o" }, ";", function()
  repeat_move(false)
end, { desc = "Repeat last Treesitter, f/F/t/T, or Sneak move" })
vim.keymap.set({ "n", "x", "o" }, ",", function()
  repeat_move(true)
end, { desc = "Repeat last Treesitter, f/F/t/T, or Sneak move in opposite direction" })

-- Treesitter fold appearance (foldmethod/foldexpr attach per window in attach_treesitter)
vim.opt.foldtext = ""                    -- Keep the exact first line and its syntax highlighting
vim.opt.fillchars:append({ fold = " " }) -- Replace trailing dashes/dots with clean empty space

-- Diff folds hide unchanged lines, so foldtext="" (first line only) makes
-- them look like ordinary code. Show a line count in diff windows instead.
function _G.DiffFoldText()
  local count = vim.v.foldend - vim.v.foldstart + 1
  return string.format("··· %d unchanged lines ···", count)
end

local diff_foldtext = "v:lua.DiffFoldText()"

-- Entering diff mode: use the count foldtext. Leaving it: drop that
-- foldtext and put back treesitter folds that diff mode displaced.
local function sync_diff_windows()
  local still_tracking = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local is_diff = vim.wo[win].diff
      local local_ft = vim.wo[win].foldtext
      if is_diff then
        still_tracking = true
        if local_ft ~= diff_foldtext then
          vim.api.nvim_set_option_value("foldtext", diff_foldtext,
            { win = win, scope = "local" })
        end
      else
        if local_ft == diff_foldtext then
          vim.api.nvim_win_call(win, function()
            vim.cmd("setlocal foldtext<")
          end)
        end
        if vim.w[win].ts_fold_pending then
          if has_treesitter_folds(vim.api.nvim_win_get_buf(win)) then
            set_treesitter_fold(win)
          else
            vim.w[win].ts_fold_pending = nil
          end
        end
      end
    end
  end
  diff_tracking = still_tracking
end

vim.api.nvim_create_autocmd(
  { "OptionSet", "DiffUpdated", "VimEnter", "WinEnter", "BufWinEnter" },
  {
    callback = function(args)
      if args.event == "OptionSet" then
        if args.match ~= "diff" then
          return
        end
        -- :diffoff restores the pre-diff 'foldmethod' even when diff mode
        -- already ended (closeoff), so re-apply treesitter folds after it.
        if not vim.wo.diff
          and has_treesitter_folds(vim.api.nvim_get_current_buf())
        then
          vim.w.ts_fold_pending = true
        end
      end
      diff_tracking = true
      vim.schedule(sync_diff_windows)
    end,
  }
)
-- :diffoff in the last diff window fires neither DiffUpdated nor
-- OptionSet, so SafeState catches it once Neovim is idle again.
vim.api.nvim_create_autocmd("SafeState", {
  callback = function()
    if diff_tracking then
      sync_diff_windows()
    end
  end,
})

-- Sticky headers (nvim-treesitter-context)
require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  trim_scope = "outer",
})
vim.keymap.set("n", "[k", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Jump to sticky treesitter context" })

require('bqf').setup({
  preview = {
    win_height = 30,
    win_vheight = 30,
  },
})

require("touchup").setup({
  bullets = { enabled = true, icons = { "✸", "✿", "✦", "✧" } },
  checkboxes = { enabled = true },
  code_blocks = { enabled = true },
  markers = { enabled = true },
  quotes = { enabled = true },
  enter = { enabled = true },
})
