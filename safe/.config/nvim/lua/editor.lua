-- [nfnl] fnl/editor.fnl
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
local scope_grp = vim.api.nvim_create_augroup("ScopeManager", {clear = true})
local buffer_tab = {}
local tab_buffers = {}
local function _1_()
  local tab = vim.api.nvim_get_current_tabpage()
  local bufs = tab_buffers[tab]
  if ("table" == type(bufs)) then
    for _, buf in ipairs(bufs) do
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_set_option_value("buflisted", true, {buf = buf})
      else
      end
    end
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("TabEnter", {group = scope_grp, callback = _1_})
local function _4_()
  local tab = vim.api.nvim_get_current_tabpage()
  local bufs = tab_buffers[tab]
  if ("table" == type(bufs)) then
    for _, buf in ipairs(bufs) do
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_set_option_value("buflisted", false, {buf = buf})
      else
      end
    end
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("TabLeave", {group = scope_grp, callback = _4_})
local function _7_(ev)
  local bt = vim.api.nvim_get_option_value("buftype", {buf = ev.buf})
  local bn = vim.api.nvim_buf_get_name(ev.buf)
  if (("" == bt) and not bn:find("conjure-log-")) then
    local current = vim.api.nvim_get_current_tabpage()
    local buf_id = ev.buf
    local home = buffer_tab[buf_id]
    if (home == nil) then
      buffer_tab[buf_id] = current
      if (nil == tab_buffers[current]) then
        tab_buffers[current] = {}
      else
      end
      return table.insert(tab_buffers[current], buf_id)
    elseif (home == current) then
      return nil
    elseif (nil ~= home) then
      local target = home
      return vim.api.nvim_set_current_tabpage(target)
    else
      return nil
    end
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufEnter", {group = scope_grp, callback = _7_})
local function is_buffer_empty_and_clean_3f(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local modified = vim.api.nvim_get_option_value("modified", {buf = buf})
  local buftype = vim.api.nvim_get_option_value("buftype", {buf = buf})
  local line_count = vim.api.nvim_buf_line_count(buf)
  local first_line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
  return ((name == "") and (modified == false) and (buftype == "") and (line_count == 1) and ((first_line == "") or (first_line == nil)))
end
local function move_buffer_to_tab(target_tab_index)
  local buf = vim.api.nvim_get_current_buf()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local all_tabs = vim.api.nvim_list_tabpages()
  local target_tab = all_tabs[target_tab_index]
  if (target_tab and (current_tab ~= target_tab)) then
    do
      local current_list = tab_buffers[current_tab]
      if current_list then
        for i, b in ipairs(current_list) do
          if (b == buf) then
            table.remove(current_list, i)
          else
          end
        end
      else
      end
    end
    buffer_tab[buf] = target_tab
    if (nil == tab_buffers[target_tab]) then
      tab_buffers[target_tab] = {}
    else
    end
    table.insert(tab_buffers[target_tab], buf)
    do
      local target_wins = vim.api.nvim_tabpage_list_wins(target_tab)
      for _, win in ipairs(target_wins) do
        local wbuf = vim.api.nvim_win_get_buf(win)
        if is_buffer_empty_and_clean_3f(wbuf) then
          vim.api.nvim_win_set_buf(win, buf)
        else
        end
      end
    end
    do
      local target_list = tab_buffers[target_tab]
      for i, b in ipairs(target_list) do
        if ((b ~= buf) and is_buffer_empty_and_clean_3f(b)) then
          table.remove(target_list, i)
          local function _15_()
            return vim.api.nvim_buf_delete(b, {force = true})
          end
          pcall(_15_)
        else
        end
      end
    end
    do
      local current_list = tab_buffers[current_tab]
      if ((nil == current_list) or (0 == #current_list)) then
        vim.cmd("enew")
      else
        local next_buf = current_list[1]
        vim.api.nvim_set_current_buf(next_buf)
      end
    end
    vim.api.nvim_set_option_value("buflisted", false, {buf = buf})
    if (0 == #tab_buffers[current_tab]) then
      return vim.cmd("enew")
    else
      return vim.cmd("bprevious")
    end
  else
    return nil
  end
end
local function _20_(opts)
  return move_buffer_to_tab(tonumber(opts.args))
end
vim.api.nvim_create_user_command("ScopeMove", _20_, {nargs = 1})
local function scope_tab_close(opts)
  local current_tab = vim.api.nvim_get_current_tabpage()
  local bufs = tab_buffers[current_tab]
  local force_orig_3f = opts.bang
  local dirty_names = {}
  local all_valid_bufs = {}
  if (bufs and (#bufs > 0)) then
    for _, buf_id in ipairs(bufs) do
      if vim.api.nvim_buf_is_valid(buf_id) then
        table.insert(all_valid_bufs, buf_id)
        if vim.api.nvim_get_option_value("modified", {buf = buf_id}) then
          local name = vim.api.nvim_buf_get_name(buf_id)
          local short_name
          if (name == "") then
            short_name = "[No Name]"
          else
            short_name = vim.fn.fnamemodify(name, ":t")
          end
          table.insert(dirty_names, short_name)
        else
        end
      else
      end
    end
  else
  end
  local proceed_3f = true
  local final_force_3f = force_orig_3f
  if ((#dirty_names > 0) and not force_orig_3f) then
    local msg = ("The following buffers are unsaved:\n  \226\128\162 " .. table.concat(dirty_names, "\n  \226\128\162 ") .. "\n\nDiscard changes and close tab?")
    local choice = vim.fn.confirm(msg, "&Yes, Discard All\n&No, Cancel", 2)
    if (choice == 1) then
      final_force_3f = true
    else
      proceed_3f = false
    end
  else
  end
  if proceed_3f then
    for _, buf_id in ipairs(all_valid_bufs) do
      local function _27_()
        return vim.api.nvim_buf_delete(buf_id, {force = final_force_3f})
      end
      pcall(_27_)
    end
    vim.cmd("tabclose")
    tab_buffers[current_tab] = nil
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_user_command("ScopeClose", scope_tab_close, {bang = true})
return vim.cmd("cabbrev tabclose ScopeClose")
