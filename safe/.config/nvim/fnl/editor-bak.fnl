;; =============================================================================
;; SCOPE MANAGER: Workspace-Based Buffer Scoping (Full Command Suite)
;; =============================================================================

(set vim.opt.number true)
(set vim.opt.relativenumber true)
(set vim.opt.cursorline true)

(set vim.opt.tabstop 2)
(set vim.opt.shiftwidth 2)
(set vim.opt.expandtab true)
(set vim.opt.softtabstop 2)
(set vim.opt.smartindent true)

;; Native routing: sbuffer/stag jump tabs, buffer forces local
(set vim.opt.switchbuf "useopen,usetab")

(local scope-grp (vim.api.nvim_create_augroup :ScopeManager {:clear true}))
(local tab-buffers {}) ;; {tab-id {buf-id true}} - The Librarian's Catalog

;; --- 1. THE LIBRARIAN (Visibility Logic) ---

(fn _G.sync-buffer-visibility []
  (let [current-tab (vim.api.nvim_get_current_tabpage)
        all-bufs (vim.api.nvim_list_bufs)
        owned-set (or (. tab-buffers current-tab) {})]
    
    (vim.opt.eventignore:append :BufDelete)
    (each [_ buf-id (ipairs all-bufs)]
      (when (vim.api.nvim_buf_is_valid buf-id)
        (let [bn (vim.api.nvim_buf_get_name buf-id)
              currently-listed? (vim.api.nvim_get_option_value :buflisted {:buf buf-id})]
          
          ;; Keep global buffers (like Conjure logs) always listed
          (when (not (bn:find :conjure-log-))
            (if (. owned-set buf-id)
                (when (not currently-listed?)
                  (vim.api.nvim_set_option_value :buflisted true {:buf buf-id}))
                (when currently-listed?
                  (vim.api.nvim_set_option_value :buflisted false {:buf buf-id})))))))
    (vim.opt.eventignore:remove :BufDelete)))

;; --- 2. THE AUTO-ADOPTION SYSTEM ---

(vim.api.nvim_create_autocmd [:TabEnter :TabLeave]
  {:group scope-grp :callback (fn [] (_G.sync-buffer-visibility))})

(vim.api.nvim_create_autocmd :BufEnter
  {:group scope-grp
   :callback (fn [ev]
               (let [bt (vim.api.nvim_get_option_value :buftype {:buf ev.buf})
                     bn (vim.api.nvim_buf_get_name ev.buf)]
                 (when (and (= "" bt) (not (bn:find :conjure-log-)))
                   (let [current-tab (vim.api.nvim_get_current_tabpage)]
                     (when (= nil (. tab-buffers current-tab))
                       (tset tab-buffers current-tab {}))
                     ;; Mark buffer as 'owned' by this tab library
                     (tset (. tab-buffers current-tab) ev.buf true)
                     (_G.sync-buffer-visibility)))))})

(vim.api.nvim_create_autocmd [:BufDelete :BufWipeout]
  {:group scope-grp
   :callback (fn [ev]
               ;; Purge buffer from all libraries when deleted from memory
               (each [_ owned-set (pairs tab-buffers)]
                 (tset owned-set ev.buf nil)))})

;; --- 3. THE MANUAL HANDOFF (ScopeMove) ---

(fn move-buffer-to-tab [target-tab-index ?buf-id]
  (let [buf (or ?buf-id (vim.api.nvim_get_current_buf))
        current-tab (vim.api.nvim_get_current_tabpage)
        all-tabs (vim.api.nvim_list_tabpages)
        target-tab (. all-tabs target-tab-index)]
    
    (when (and target-tab (vim.api.nvim_buf_is_valid buf))
      ;; 1. UNBIND from current tab library
      (let [current-set (. tab-buffers current-tab)]
        (when current-set (tset current-set buf nil)))

      ;; 2. BIND to target tab library
      (when (= nil (. tab-buffers target-tab)) (tset tab-buffers target-tab {}))
      (tset (. tab-buffers target-tab) buf true)

      ;; 3. EVACUATE if visible here (Keep the layout clean)
      (let [wins (vim.api.nvim_tabpage_list_wins current-tab)]
        (each [_ win (ipairs wins)]
          (when (= (vim.api.nvim_win_get_buf win) buf)
            (vim.api.nvim_win_call win #(if (not (pcall vim.cmd :bprevious)) (vim.cmd :enew))))))

      ;; 4. REFRESH
      (_G.sync-buffer-visibility)
      (vim.notify (.. "Moved buffer to tab " target-tab-index)))))

;; --- 4. THE SMART EXIT LOGIC ---

(fn buf-delete [opts]
  (let [buf (if (or (= opts.args "") (= opts.args nil)) (vim.api.nvim_get_current_buf) (tonumber opts.args))
        force? opts.bang]
    (when (vim.api.nvim_buf_is_valid buf)
      (let [modified? (vim.api.nvim_get_option_value :modified {:buf buf})]
        (var proceed? true)
        (when (and modified? (not force?))
          (let [choice (vim.fn.confirm (.. "Save " (vim.api.nvim_buf_get_name buf) "?") "&Yes\n&No\n&Cancel" 1)]
            (if (= choice 1) (vim.cmd :w) (= choice 2) (set proceed? true) (set proceed? false))))
        (when proceed?
          (let [wins (vim.fn.win_findbuf buf)]
            (each [_ win (ipairs wins)]
              (vim.api.nvim_win_call win #(if (not (pcall vim.cmd :bprevious)) (vim.cmd :enew)))))
          (pcall #(vim.api.nvim_buf_delete buf {:force (or force? modified?)})))))))

(fn scope-tab-close [opts]
  (let [current-tab (vim.api.nvim_get_current_tabpage)
        owned-set (or (. tab-buffers current-tab) {})
        tab-count (length (vim.api.nvim_list_tabpages))
        force? opts.bang]
    (each [buf-id _ (pairs owned-set)]
      (pcall #(vim.api.nvim_buf_delete buf-id {:force force?})))
    (if (> tab-count 1) (vim.cmd :tabclose) (vim.cmd :enew))
    (tset tab-buffers current-tab nil)))

(fn close-window [opts]
  (let [buf (vim.api.nvim_get_current_buf)
        force? opts.bang
        bt (vim.api.nvim_get_option_value :buftype {:buf buf})
        wins (icollect [_ w (ipairs (vim.api.nvim_tabpage_list_wins 0))]
               (let [cfg (vim.api.nvim_win_get_config w)] 
                 (when (and (= cfg.relative "") (= cfg.focusable true)) w)))
        win-count (length wins)
        tab-count (length (vim.api.nvim_list_tabpages))]
    (if (not= bt "")
        (if force? (vim.cmd :q!) (vim.cmd :q))
        (match [win-count tab-count]
          [1 1] (if force? (vim.cmd :qa!) (vim.cmd "confirm qa"))
          [1 _] (scope-tab-close opts)
          _ (do (vim.cmd :close) (buf-delete {:args (tostring buf) :bang force?}))))))

;; --- 5. REGISTRATION ---

(vim.api.nvim_create_user_command :ScopeMove 
  (fn [opts] (let [a opts.fargs] (move-buffer-to-tab (tonumber (. a 1)) (tonumber (. a 2))))) 
  {:nargs "+" :desc "Move buffer ownership to another tab library"})

(vim.api.nvim_create_user_command :ScopeClose scope-tab-close {:bang true :desc "Kill tab's buffer scope and close tab"})

;; Base Deletion Commands
(vim.api.nvim_create_user_command :BufDelete (fn [opts] (buf-delete opts)) {:bang true :nargs "?"})
(vim.api.nvim_create_user_command :CloseWindow (fn [opts] (close-window opts)) {:bang true})

;; Write + Delete Commands
(vim.api.nvim_create_user_command :WriteBufDelete 
  (fn [opts] (when (pcall vim.cmd (if opts.bang :write! :write)) (buf-delete opts))) 
  {:bang true})

(vim.api.nvim_create_user_command :WriteCloseWindow 
  (fn [opts] (when (pcall vim.cmd (if opts.bang :write! :write)) (close-window opts))) 
  {:bang true})

(set _G.rename_tab (fn [name] (vim.api.nvim_tabpage_set_var 0 :tab_name name)))

; (fn _G.smart-open [target]
;   (let [as-num (tonumber target)
;         ;; bufnr returns the ID if the path is already loaded, else -1
;         buf-id (if (and as-num (vim.api.nvim_buf_is_valid as-num))
;                    as-num
;                    (vim.fn.bufnr target))
;         current-tab (vim.api.nvim_get_current_tabpage)
;         swb-list (vim.opt.switchbuf:get)
;         owned-set (or (. tab-buffers current-tab) {})]
;
;     (if (= buf-id -1)
;         ;; --- CASE 1: Disk Object (New File) ---
;         ;; It's not in memory, so it can't be in a window or a tab library.
;         (vim.cmd (.. "edit " (vim.fn.fnameescape target)))
;
;         ;; --- CASE 2: Memory Object (Existing Buffer) ---
;         ;; We run the Librarian-First Logic Ladder
;         (let [librarian-check (fn []
;                                 (if (. owned-set buf-id)
;                                     (do (vim.cmd (.. "buffer " buf-id)) true)
;                                     false))]
;           (var handled? false)
;           (each [_ policy (ipairs swb-list)]
;             (when (not handled?)
;               (match policy
;                 :useopen (let [wins (vim.api.nvim_tabpage_list_wins 0)
;                                target-win (accumulate [f nil _ win (ipairs wins)]
;                                             (if (= (vim.api.nvim_win_get_buf win) buf-id) win f))]
;                            (if target-win
;                                (do (vim.api.nvim_set_current_win target-win) (set handled? true))
;                                (set handled? (librarian-check))))
;                 :usetab (let [all-tabs (vim.api.nvim_list_tabpages)
;                               loc (accumulate [fl nil _ tab (ipairs all-tabs)]
;                                     (if fl fl
;                                         (let [wins (vim.api.nvim_tabpage_list_wins tab)
;                                               w (accumulate [fw nil _ win (ipairs wins)]
;                                                   (if (= (vim.api.nvim_win_get_buf win) buf-id) win fw))]
;                                           (if w {:tab tab :win w} nil))))]
;                           (when loc
;                             (vim.api.nvim_set_current_tabpage loc.tab)
;                             (vim.api.nvim_set_current_win loc.win)
;                             (set handled? true)))
;                 :newtab (do (vim.cmd :tabnew) (vim.cmd (.. "buffer " buf-id)) (set handled? true))
;                 :vsplit (do (vim.cmd :vsplit) (vim.cmd (.. "buffer " buf-id)) (set handled? true))
;                 :split  (do (vim.cmd :split)  (vim.cmd (.. "buffer " buf-id)) (set handled? true)))))
;
;           ;; FALLBACK: If switchbuf didn't jump us, we use the buffer ID.
;           (when (not handled?)
;             (vim.cmd (.. "buffer " buf-id)))))))

(fn _G.smart-open [target]
  (let [as-num (tonumber target)
        buf-id (if (and as-num (vim.api.nvim_buf_is_valid as-num))
                   as-num
                   (vim.fn.bufnr target))
        current-tab (vim.api.nvim_get_current_tabpage)
        swb-list (vim.opt.switchbuf:get)
        owned-set (or (. tab-buffers current-tab) {})]

    (if (= buf-id -1)
        (vim.cmd (.. "edit " (vim.fn.fnameescape target)))
        
        (let [librarian-check (fn []
                                (if (. owned-set buf-id)
                                    (do (vim.cmd (.. "buffer " buf-id)) true)
                                    false))]
          (var handled? false)
          (each [_ policy (ipairs swb-list)]
            (when (not handled?)
              (match policy
                :useopen (let [wins (vim.api.nvim_tabpage_list_wins 0)
                               target-win (accumulate [f nil _ win (ipairs wins)]
                                            (if (= (vim.api.nvim_win_get_buf win) buf-id) win f))]
                           (if target-win
                               (do (vim.api.nvim_set_current_win target-win) (set handled? true))
                               (set handled? (librarian-check))))

                :usetab (let [all-tabs (vim.api.nvim_list_tabpages)
                              ;; 1. Check for a VISIBLE window in any tab
                              loc (accumulate [fl nil _ tab (ipairs all-tabs)]
                                    (if fl fl
                                        (let [wins (vim.api.nvim_tabpage_list_wins tab)
                                              w (accumulate [fw nil _ win (ipairs wins)]
                                                  (if (= (vim.api.nvim_win_get_buf win) buf-id) win fw))]
                                          (if w {:tab tab :win w} nil))))]
                          (if loc
                              (do (vim.api.nvim_set_current_tabpage loc.tab)
                                  (vim.api.nvim_set_current_win loc.win)
                                  (set handled? true))
                              
                              ;; 2. NEW SILO LOGIC: If not visible, check if OWNED by another tab
                              (let [owning-tab (accumulate [ot nil t-id o-set (pairs tab-buffers)]
                                                 (if (and (not ot) (. o-set buf-id)) t-id ot))]
                                (when owning-tab
                                  (vim.api.nvim_set_current_tabpage owning-tab)
                                  (vim.cmd (.. "buffer " buf-id))
                                  (set handled? true)))))

                :newtab (do (vim.cmd :tabnew) (vim.cmd (.. "buffer " buf-id)) (set handled? true))
                :vsplit (do (vim.cmd :vsplit) (vim.cmd (.. "buffer " buf-id)) (set handled? true))
                :split  (do (vim.cmd :split)  (vim.cmd (.. "buffer " buf-id)) (set handled? true)))))
          
          ;; FALLBACK: Only runs if the buffer is NOT in any tab's library
          (when (not handled?)
            (vim.cmd (.. "buffer " buf-id)))))))

(vim.api.nvim_create_user_command :B (fn [args] (_G.smart-open (. args.fargs 1))) {:nargs 1 :complete :buffer})


