(set vim.opt.number true)
(set vim.opt.relativenumber true)
(set vim.opt.cursorline true)

; required scope for autocmd events so on reload of config its replaces instead fo appended
(local scope-grp (vim.api.nvim_create_augroup :ScopeManager {:clear true}))
(local buffer-tab {})
(local tab-buffers {})

(vim.api.nvim_create_autocmd :TabEnter
  {:group scope-grp
   :callback (fn []
               (let [tab (vim.api.nvim_get_current_tabpage)
                     bufs (. tab-buffers tab)]
                 ;; Only loop if bufs is actually a table
                 (when (= :table (type bufs))
                   (each [_ buf (ipairs bufs)]
                     (when (vim.api.nvim_buf_is_valid buf)
                       (vim.api.nvim_set_option_value :buflisted true {:buf buf}))))))})

(vim.api.nvim_create_autocmd :TabLeave
  {:group scope-grp
   :callback (fn []
               (let [tab (vim.api.nvim_get_current_tabpage)
                     bufs (. tab-buffers tab)]
                 ;; Safety check: only unlist if the table exists
                 (when (= :table (type bufs))
                   (each [_ buf (ipairs bufs)]
                     (when (vim.api.nvim_buf_is_valid buf)
                       (vim.api.nvim_set_option_value :buflisted false {:buf buf}))))))})

(vim.api.nvim_create_autocmd :BufEnter
  {:group scope-grp
   :callback (fn [ev]
               (let [bt (vim.api.nvim_get_option_value :buftype {:buf ev.buf})
                     bn (vim.api.nvim_buf_get_name ev.buf)]
                 ;; Explicitly ignore nofile and conjure logs
                 (when (and (= "" bt) 
                            (not (bn:find "conjure-log-")))
                   (let [current (vim.api.nvim_get_current_tabpage)
                         buf-id ev.buf
                         home (. buffer-tab buf-id)]
                     (match home
                       nil (do
                             (tset buffer-tab buf-id current)
                             (when (= nil (. tab-buffers current))
                               (tset tab-buffers current {}))
                             (table.insert (. tab-buffers current) buf-id))
                       
                       current nil
                       target (vim.api.nvim_set_current_tabpage target))))))})

(fn is-buffer-empty-and-clean? [buf]
  (let [name (vim.api.nvim_buf_get_name buf)
        modified (vim.api.nvim_get_option_value :modified {:buf buf})
        buftype (vim.api.nvim_get_option_value :buftype {:buf buf})
        line-count (vim.api.nvim_buf_line_count buf)
        first-line (. (vim.api.nvim_buf_get_lines buf 0 1 false) 1)]
    (and (= name "") 
         (= modified false) 
         (= buftype "") 
         (= line-count 1) 
         (or (= first-line "") (= first-line nil)))))

(fn move-buffer-to-tab [target-tab-index]
  (let [buf (vim.api.nvim_get_current_buf)
        current-tab (vim.api.nvim_get_current_tabpage)
        all-tabs (vim.api.nvim_list_tabpages)
        target-tab (. all-tabs target-tab-index)]
    
    (when (and target-tab (not= current-tab target-tab))
      ;; 1. TRACKING: Remove from current, add to target
      (let [current-list (. tab-buffers current-tab)]
        (when current-list
          (each [i b (ipairs current-list)]
            (if (= b buf) (table.remove current-list i)))))
      
      (tset buffer-tab buf target-tab)
      (when (= nil (. tab-buffers target-tab))
        (tset tab-buffers target-tab {}))
      (table.insert (. tab-buffers target-tab) buf)

      ;; 2. THE FIX: Force the target tab's window to "anchor" onto the moved buffer
      ;; This prevents the tab from closing when we delete the empty one later.
      (let [target-wins (vim.api.nvim_tabpage_list_wins target-tab)]
        (each [_ win (ipairs target-wins)]
          ;; If the window is showing an empty buffer, switch it to our moved 'buf'
          (let [wbuf (vim.api.nvim_win_get_buf win)]
            (when (is-buffer-empty-and-clean? wbuf)
              (vim.api.nvim_win_set_buf win buf)))))

      ;; 3. CLEANUP: Now it is safe to delete the empty buffer
      (let [target-list (. tab-buffers target-tab)]
        (each [i b (ipairs target-list)]
          (when (and (not= b buf) (is-buffer-empty-and-clean? b))
            (table.remove target-list i)
            (pcall #(vim.api.nvim_buf_delete b {:force true})))))

	;; 4. LOCAL UI: Move the window away BEFORE hiding the buffer
      (let [current-list (. tab-buffers current-tab)]
        (if (or (= nil current-list) (= 0 (length current-list)))
            ;; No buffers left in this tab? Create a blank one.
            (vim.cmd :enew)
            ;; Otherwise, jump to another buffer that DOES belong here.
            (let [next-buf (. current-list 1)]
              (vim.api.nvim_set_current_buf next-buf))))

      ;; NOW it is safe to hide the buffer because we aren't looking at it.
      (vim.api.nvim_set_option_value :buflisted false {:buf buf})
      
      ;; Move the current window away from the buffer we just 'sent away'
      (if (= 0 (length (. tab-buffers current-tab)))
          (vim.cmd :enew)
          (vim.cmd :bprevious)))))

;; Create a command: :ScopeMove 2 (to move current buffer to tab 2)
(vim.api.nvim_create_user_command :ScopeMove 
  (fn [opts] (move-buffer-to-tab (tonumber opts.args))) 
  {:nargs 1})

(fn scope-tab-close [opts]
  (let [current-tab (vim.api.nvim_get_current_tabpage)
        bufs (. tab-buffers current-tab)
        force-orig? opts.bang]
    
    (var dirty-names [])
    (var all-valid-bufs [])

    ;; 1. Audit: Find out exactly what we have
    (when (and bufs (> (length bufs) 0))
      (each [_ buf-id (ipairs bufs)]
        (when (vim.api.nvim_buf_is_valid buf-id)
          (table.insert all-valid-bufs buf-id)
          ;; Check if buffer is modified
          (when (vim.api.nvim_get_option_value :modified {:buf buf-id})
            (let [name (vim.api.nvim_buf_get_name buf-id)
                  short-name (if (= name "") "[No Name]" (vim.fn.fnamemodify name ":t"))]
              (table.insert dirty-names short-name))))))

    ;; 2. The Decision Gate
    (var proceed? true)
    (var final-force? force-orig?)

    (when (and (> (length dirty-names) 0) (not force-orig?))
      (let [msg (.. "The following buffers are unsaved:\n  • " 
                    (table.concat dirty-names "\n  • ")
                    "\n\nDiscard changes and close tab?")
            choice (vim.fn.confirm msg "&Yes, Discard All\n&No, Cancel" 2)]
        (if (= choice 1)
            (set final-force? true)
            (set proceed? false))))

    ;; 3. Execution
    (when proceed?
      (each [_ buf-id (ipairs all-valid-bufs)]
        ;; Use pcall just in case of unexpected LSP/plugin locks
        (pcall #(vim.api.nvim_buf_delete buf-id {:force final-force?})))
      
      (vim.cmd :tabclose)
      (tset tab-buffers current-tab nil))))

(vim.api.nvim_create_user_command :ScopeClose scope-tab-close {:bang true})
(vim.cmd "cabbrev tabclose ScopeClose")
