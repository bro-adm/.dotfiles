-- [nfnl] fnl/try.fnl
local function _1_(name)
  return print(("Hello " .. name))
end
do local _ = {hello = _1_} end
local function _2_(name)
  return print(("Greetings " .. name))
end
_G.greet = _2_
_G.greet("liel")
local function _3_(opts)
  return _G.greet(opts.args)
end
vim.api.nvim_create_user_command("Greet", _3_, {nargs = 1})
vim.api.nvim_list_bufs()
do
  local bufs = vim.api.nvim_list_bufs()
  local tbl_26_ = {}
  local i_27_ = 0
  for _, id in ipairs(bufs) do
    local val_28_
    do
      local name = vim.api.nvim_buf_get_name(id)
      val_28_ = (id .. ": " .. name)
    end
    if (nil ~= val_28_) then
      i_27_ = (i_27_ + 1)
      tbl_26_[i_27_] = val_28_
    else
    end
  end
end
local function _5_(name)
  return vim.api.nvim_tabpage_set_var(0, "tab_name", name)
end
_G.rename_tab = _5_
return nil
