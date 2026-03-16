
{:hello (fn [name] (print (.. "Hello " name)))}

(set _G.greet (fn [name] (print (.. "Greetings " name))))

(_G.greet "liel")

(vim.api.nvim_create_user_command 
  :Greet 
  (fn [opts] (_G.greet opts.args)) 
  {:nargs 1})

(vim.api.nvim_list_bufs)

(let [bufs (vim.api.nvim_list_bufs)]
  (icollect [_ id (ipairs bufs)]
    (let [name (vim.api.nvim_buf_get_name id)]
      (.. id ": " name))))

(set _G.rename_tab (fn [name]
                    (vim.api.nvim_tabpage_set_var 0 :tab_name name)))
