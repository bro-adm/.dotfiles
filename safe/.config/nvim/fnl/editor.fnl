;; =============================================================================
;; LIBRARIAN SCOPE MANAGER: The Intentional Silo (Full Functional Suite)
;; =============================================================================

(set vim.opt.number true)
(set vim.opt.relativenumber true)
(set vim.opt.cursorline true)
(set vim.opt.tabstop 2)
(set vim.opt.shiftwidth 2)
(set vim.opt.expandtab true)
(set vim.opt.softtabstop 2)
(set vim.opt.smartindent true)

;; Native routing: useopen/usetab respects your existing silos
(set vim.opt.switchbuf "useopen,usetab")

(local scope-grp (vim.api.nvim_create_augroup :ScopeManager {:clear true}))
(local tab-buffers {}) ;; {tab-id {buf-id true}} - The Catalog

;; --- 1. THE ADOPTION & EVACUATION HELPERS ---

(fn adopt-buffer [buf-id]
  "Explicitly adds a buffer to the current tab's library."
  (when (and buf-id (vim.api.nvim_buf_is_valid buf-id))
    (let [current-tab (vim.api.nvim_get_current_tabpage)]
      (when (= nil (. tab-buffers current-tab))
        (tset tab-buffers current-tab {}))
      (tset (. tab-buffers current-tab) buf-id true))))

(fn smart-evacuate [win-id target-buf]
  "Moves a window to a sibling buffer in the same silo instead of enew."
  (let [current-tab (vim.api.nvim_get_current_tabpage)
        owned-set (or (. tab-buffers current-tab) {})
        next-best (accumulate [best nil b-id _ (pairs owned-set)]
                    (if (and (not best) (not= b-id target-buf) (vim.api.nvim_buf_is_valid b-id))
                        b-id best))]
    (let [cfg (vim.api.nvim_win_get_config win-id)]
      (when (= cfg.relative "")
        (vim.api.nvim_win_call win-id 
          #(if next-best
               (vim.cmd (.. "buffer " next-best))
               (vim.cmd :enew)))))))

;; --- 2. THE LIBRARIAN (Visibility & Janitor) ---

(fn _G.sync-buffer-visibility []
  (let [current-tab (vim.api.nvim_get_current_tabpage)
        all-bufs (vim.api.nvim_list_bufs)
        owned-set (or (. tab-buffers current-tab) {})
        ;; Keep track of what's visible to avoid nuking active scratchpads
        visible-bufs (accumulate [s {} _ w (ipairs (vim.api.nvim_list_wins))]
                       (do (tset s (vim.api.nvim_win_get_buf w) true) s))]

    (vim.opt.eventignore:append [:BufDelete])
    (each [_ buf-id (ipairs all-bufs)]
      (when (vim.api.nvim_buf_is_valid buf-id)
        (let [bn (vim.api.nvim_buf_get_name buf-id)
              bt (vim.api.nvim_get_option_value :buftype {:buf buf-id})
              modified? (vim.api.nvim_get_option_value :modified {:buf buf-id})
              currently-listed? (vim.api.nvim_get_option_value :buflisted {:buf buf-id})]

          ;; --- THE JANITOR ---
          ;; Nuke empty [No Name] buffers if they aren't visible anywhere.
          (if (and (= bn "") (= bt "") (not modified?) (not (. visible-bufs buf-id)))
              (pcall #(vim.api.nvim_buf_delete buf-id {:force true}))

              ;; --- SCOPE ENFORCEMENT ---
              ;; Keep global buffers (like Conjure logs) always listed
              (when (= bt "")
                (when (not (bn:find :conjure-log-))
                  (if (. owned-set buf-id)
                      (when (not currently-listed?)
                        (vim.api.nvim_set_option_value :buflisted true {:buf buf-id}))
                      (when currently-listed?
                        (vim.api.nvim_set_option_value :buflisted false {:buf buf-id})))))))))
    (vim.opt.eventignore:remove [:BufDelete])))

;; --- 3. AUTO-COMMANDS (Minimalist) ---

;; Auto-adopt buffers when they're entered, read, or created
(vim.api.nvim_create_autocmd [:BufEnter :BufRead :BufNewFile]
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
                     ;; Sync visibility to hide other tabs' buffers
                     (_G.sync-buffer-visibility)))))})

;; Switch silos when switching tabs - this is where the magic happens
(vim.api.nvim_create_autocmd :TabEnter
  {:group scope-grp :callback (fn [] (_G.sync-buffer-visibility))})

;; Cleanup catalog when a buffer is wiped from memory
(vim.api.nvim_create_autocmd [:BufDelete :BufWipeout]
  {:group scope-grp
   :callback (fn [ev]
               (each [_ owned-set (pairs tab-buffers)] (tset owned-set ev.buf nil)))})

;; --- 4. THE COMMAND SUITE (Smart Exits & Handoffs) ---

(fn move-buffer-to-tab [target-tab-index ?buf-id]
  (let [buf (or ?buf-id (vim.api.nvim_get_current_buf))
        current-tab (vim.api.nvim_get_current_tabpage)
        all-tabs (vim.api.nvim_list_tabpages)
        target-tab (. all-tabs target-tab-index)]
    (when (and target-tab (vim.api.nvim_buf_is_valid buf))
      ;; 1. Unbind from current
      (let [current-set (. tab-buffers current-tab)] (when current-set (tset current-set buf nil)))
      ;; 2. Bind to target
      (when (= nil (. tab-buffers target-tab)) (tset tab-buffers target-tab {}))
      (tset (. tab-buffers target-tab) buf true)
      ;; 3. Evacuate tiled windows in current tab
      (let [wins (vim.api.nvim_tabpage_list_wins current-tab)]
        (each [_ win (ipairs wins)]
          (when (= (vim.api.nvim_win_get_buf win) buf) (smart-evacuate win buf))))
      (_G.sync-buffer-visibility)
      (vim.notify (.. "Moved buffer to tab " target-tab-index)))))

(fn buf-delete [opts]
  (let [buf (if (or (= opts.args "") (= opts.args nil)) (vim.api.nvim_get_current_buf) (tonumber opts.args))
        force? opts.bang]
    (when (vim.api.nvim_buf_is_valid buf)
      (let [modified? (vim.api.nvim_get_option_value :modified {:buf buf})]
        (var proceed? true)
        (when (and modified? (not force?))
          (let [choice (vim.fn.confirm (.. "Save " (vim.api.nvim_buf_get_name buf) "?") "&Yes\n&No\n&Cancel" 1)]
            (if (= choice 1) (vim.cmd :w)
                (= choice 2) (set proceed? true)
                (set proceed? false))))
        (when proceed?
          (let [wins (vim.fn.win_findbuf buf)]
            (each [_ win (ipairs wins)] (smart-evacuate win buf)))
          (pcall #(vim.api.nvim_buf_delete buf {:force (or force? modified?)})))))))

(fn scope-tab-close [opts]
  (let [current-tab (vim.api.nvim_get_current_tabpage)
        owned-set (or (. tab-buffers current-tab) {})
        tab-count (length (vim.api.nvim_list_tabpages))
        force? opts.bang]
    (each [buf-id _ (pairs owned-set)] (pcall #(vim.api.nvim_buf_delete buf-id {:force force?})))
    (tset tab-buffers current-tab nil)
    (if (> tab-count 1) (vim.cmd :tabclose) (vim.cmd :enew))
    (_G.sync-buffer-visibility)))

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

;; --- 5. SMART OPEN (The Intentional Gatekeeper) ---

(fn _G.smart-open [target]
  (let [as-num (tonumber target)
        buf-id (if (and as-num (vim.api.nvim_buf_is_valid as-num)) as-num (vim.fn.bufnr target))
        current-tab (vim.api.nvim_get_current_tabpage)
        swb (vim.opt.switchbuf:get)
        owned (or (. tab-buffers current-tab) {})]

    (if (= buf-id -1)
        ;; New file: edit it, then adopt it.
        (do (vim.cmd (.. "edit " (vim.fn.fnameescape target)))
            (adopt-buffer (vim.api.nvim_get_current_buf)))
        
        (let [lib-check #(if (. owned buf-id) (do (vim.cmd (.. "buffer " buf-id)) true) false)]
          (var handled? false)
          (each [_ policy (ipairs swb)]
            (when (not handled?)
              (match policy
                :useopen (let [target-win (accumulate [f nil _ w (ipairs (vim.api.nvim_tabpage_list_wins 0))]
                                           (if (= (vim.api.nvim_win_get_buf w) buf-id) w f))]
                           (if target-win (do (vim.api.nvim_set_current_win target-win) (set handled? true))
                               (set handled? (lib-check))))
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
                :vsplit (do (vim.cmd :vsplit) (vim.cmd (.. "buffer " buf-id)) (set handled? true)))))
          
          ;; Fallback: Bring to current silo and adopt
          (when (not handled?) (vim.cmd (.. "buffer " buf-id)))
          (adopt-buffer (vim.api.nvim_get_current_buf))))
    (_G.sync-buffer-visibility)))

;; --- 6. REGISTRATION ---

(vim.api.nvim_create_user_command :ScopeMove 
  (fn [opts] 
    (let [a opts.fargs 
          target-tab (tonumber (. a 1))
          buf (tonumber (. a 2))] 
      (move-buffer-to-tab target-tab buf))) 
  {:nargs "+" :desc "Move buffer ownership to another tab library"})

(vim.api.nvim_create_user_command :ScopeClose scope-tab-close {:bang true :desc "Kill tab's buffer scope and close tab"})

;; Base Deletion Commands
(vim.api.nvim_create_user_command :BufDelete #(buf-delete $) {:bang true :nargs "?"})
(vim.api.nvim_create_user_command :CloseWindow #(close-window $) {:bang true})

;; Write + Delete Commands
(vim.api.nvim_create_user_command :WriteBufDelete
  (fn [opts] (when (pcall vim.cmd (if opts.bang :write! :write)) (buf-delete opts)))
  {:bang true})

(vim.api.nvim_create_user_command :WriteCloseWindow
  (fn [opts] (when (pcall vim.cmd (if opts.bang :write! :write)) (close-window opts)))
  {:bang true})

(vim.api.nvim_create_user_command :B #(_G.smart-open (. $.fargs 1)) {:nargs 1 :complete :buffer})

(set _G.rename_tab #(vim.api.nvim_tabpage_set_var 0 :tab_name $))


; (local output [])
;
; ;; Build output as a table of strings
; (table.insert output "=== TAB -> BUFFERS MAPPING ===")
;
; (if (and tab-buffers (next tab-buffers))
;     (each [tab-id buf-set (pairs tab-buffers)]
;       (table.insert output (.. "Tab " tab-id ":"))
;       (each [buf-id _ (pairs buf-set)]
;         (when (vim.api.nvim_buf_is_valid buf-id)
;           (let [bn (vim.api.nvim_buf_get_name buf-id)
;                 name (if (= bn "") "[No Name]" bn)]
;             (table.insert output (.. "  - Buffer " buf-id ": " name))))))
;     (table.insert output "  (empty)"))
;
; (table.insert output "")
; (table.insert output "=== BUFFERS -> TABS MAPPING ===")
;
; (local buf-to-tabs {})
; (when (and tab-buffers (next tab-buffers))
;   (each [tab-id buf-set (pairs tab-buffers)]
;     (each [buf-id _ (pairs buf-set)]
;       (when (= nil (. buf-to-tabs buf-id))
;         (tset buf-to-tabs buf-id []))
;       (table.insert (. buf-to-tabs buf-id) tab-id))))
;
; (if (next buf-to-tabs)
;     (each [buf-id tab-list (pairs buf-to-tabs)]
;       (when (vim.api.nvim_buf_is_valid buf-id)
;         (let [bn (vim.api.nvim_buf_get_name buf-id)
;               name (if (= bn "") "[No Name]" bn)
;               tabs (table.concat tab-list ", ")]
;           (table.insert output (.. "Buffer " buf-id " (" name "): tabs [" tabs "]")))))
;     (table.insert output "  (empty)"))
;
; (table.insert output "")
; (table.insert output "=== CURRENT STATE ===")
; (table.insert output (.. "Current tab: " (vim.api.nvim_get_current_tabpage)))
; (table.insert output (.. "Current buffer: " (vim.api.nvim_get_current_buf)))
;
; ;; Return as a single string for Conjure to display
; (table.concat output "\n")
