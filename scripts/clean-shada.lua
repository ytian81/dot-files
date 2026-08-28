#!/usr/bin/env -S nvim -l

-- =============================================================================
-- clean-shada.lua: Prune dead / unreadable file marks from Neovim ShaDa history.
--
-- Usage:
--   clean-shada [--dry-run|-n] [--verbose|-v] [custom_shada_path]
--   clean-shada --help|-h
-- =============================================================================

local args = _G.arg or {}
local dry_run = false
local verbose = false
local custom_file = nil

for _, arg in ipairs(args) do
  if arg == "--dry-run" or arg == "-n" then
    dry_run = true
  elseif arg == "--verbose" or arg == "-v" then
    verbose = true
  elseif arg == "--help" or arg == "-h" then
    print([[
clean-shada: Prune unreadable/deleted files from Neovim ShaDa (v:oldfiles) history.

Usage:
  clean-shada [OPTIONS] [SHADA_FILE]

Options:
  -n, --dry-run    Preview entries to be removed without modifying the file
  -v, --verbose    Show detailed list of pruned files and their reference counts
  -h, --help       Show this help message
]])
    os.exit(0)
  elseif not arg:match("^%-") then
    custom_file = arg
  end
end

local state_shada = vim.fn.stdpath("state") .. "/shada/main.shada"
local data_shada = vim.fn.stdpath("data") .. "/shada/main.shada"
local shada_file = custom_file
  or (vim.fn.filereadable(state_shada) == 1 and state_shada)
  or (vim.fn.filereadable(data_shada) == 1 and data_shada)
  or nil

if not shada_file or vim.fn.filereadable(shada_file) ~= 1 then
  io.stderr:write("Error: ShaDa file not found at " .. (shada_file or "(nil)") .. "\n")
  os.exit(1)
end

print("Inspecting ShaDa: " .. shada_file)
local f = assert(io.open(shada_file, "rb"))
local data = f:read("*a")
f:close()

local lines = vim.fn["shada#get_strings"](data)
local cache = {}

local function is_readable(path)
  if cache[path] ~= nil then return cache[path] end
  -- Ignore custom URI schemes (e.g., fugitive://, term://)
  if path:match("^%a[%w+.-]*://") then
    cache[path] = false
    return false
  end
  local tf = io.open(path, "r")
  if tf then
    tf:close()
    cache[path] = true
    return true
  end
  cache[path] = false
  return false
end

-- Split into distinct ShaDa entry blocks
local blocks, cur_block = {}, {}
for _, line in ipairs(lines) do
  if line:match("^%a[%a%s]* with timestamp") then
    if #cur_block > 0 then table.insert(blocks, cur_block) end
    cur_block = { line }
  else
    table.insert(cur_block, line)
  end
end
if #cur_block > 0 then table.insert(blocks, cur_block) end

local filtered_blocks = {}
local pruned_count = 0
local dead_files = {}

for _, block in ipairs(blocks) do
  local block_text = table.concat(block, "\n")
  local file_path = block_text:match("file name%s+\"([^\"]+)\"")
  if file_path and not is_readable(file_path) then
    pruned_count = pruned_count + 1
    dead_files[file_path] = (dead_files[file_path] or 0) + 1
  else
    table.insert(filtered_blocks, block)
  end
end

local dead_file_count = vim.tbl_count(dead_files)
if dead_file_count == 0 then
  print("ShaDa file is already clean. No dead entries found.")
  os.exit(0)
end

print(string.format("Found %d dead entry block(s) across %d unreadable file(s):", pruned_count, dead_file_count))
if verbose or dry_run then
  for path, count in pairs(dead_files) do
    print(string.format("  - [%d ref(s)] %s", count, path))
  end
end

if dry_run then
  print("\n[dry-run] No changes written.")
  os.exit(0)
end

-- Safety backup
local bak_file = shada_file .. ".bak"
os.execute(string.format("cp %q %q", shada_file, bak_file))
print("Backup created at: " .. bak_file)

-- Convert filtered blocks back to binary ShaDa
local new_lines = {}
for _, block in ipairs(filtered_blocks) do
  for _, line in ipairs(block) do
    table.insert(new_lines, line)
  end
end

local bin = vim.fn["shada#get_binstrings"](new_lines)
vim.fn.writefile(bin, shada_file, "b")

print("Done! Successfully optimized ShaDa history.")
