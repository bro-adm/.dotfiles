(local M {})

(local SCOPES {:global "cd" :tab "tcd" :window "lcd"})

(fn zoxide-exec [args]
  (let [obj (vim.system ["zoxide" (unpack args)] {:text true})]
    (let [out (obj:wait)]
      (if (= out.code 0)
          (vim.split out.stdout "\n" {:trimempty true})
          []))))

(fn M.z [query scope bang]
  (let [cd-cmd (. SCOPES (or scope :global))]
    (if bang
        ;; Direct jump
        (let [results (zoxide-exec ["query" query])]
          (when (> (length results) 0)
            (let [path (. results 1)]
              (vim.cmd (.. cd-cmd " " path))
              (vim.system ["zoxide" "add" path]))))

        ;; Use the standard UI selector (which Snacks intercepts)
        (let [results (zoxide-exec ["query" "--list" query])]
          (if (= (length results) 0)
              (vim.notify "Zoxide: No matches found" vim.log.levels.WARN)
              (vim.ui.select 
                results 
                {:prompt (.. cd-cmd " to...")}
                (fn [choice]
                  (when choice
                    (vim.cmd (.. cd-cmd " " choice))
                    (vim.system ["zoxide" "add" choice])))))))))

(fn M.setup []
  (each [scope suffix (pairs {:global "" :tab "t" :window "w"})]
    (vim.api.nvim_create_user_command 
      (.. "Z" suffix)
      (fn [opts] (M.z opts.args scope opts.bang))
      {:nargs "+" :bang true})))

(M.setup)

M

; ;; =============================================================================
; ;; ZOXIDE MODULE: Fix for Non-Persistent CWD
; ;; =============================================================================
;
; (local M {})
;
; ;; Polyfill for unpack
; (local unpack (or table.unpack _G.unpack))
;
; (local SCOPES {:global "cd" :tab "tcd" :window "lcd"})
;
; (fn zoxide-exec [args]
;   (let [obj (vim.system ["zoxide" (unpack args)] {:text true})]
;     (let [out (obj:wait)]
;       (if (= out.code 0)
;           (vim.split out.stdout "\n" {:trimempty true})
;           []))))
;
; (fn M.z [query scope bang]
;   (let [cd-cmd (. SCOPES (or scope :global))
;         ;; Capture the current window and tab before any UI opens
;         target-win (vim.api.nvim_get_current_win)]
;
;     (if (and bang (not= query ""))
;         (let [results (zoxide-exec ["query" query])]
;           (when (> (length results) 0)
;             (let [path (. results 1)]
;               (vim.api.nvim_win_call target-win 
;                 #(vim.cmd (.. cd-cmd " " (vim.fn.fnameescape path))))
;               (vim.system ["zoxide" "add" path]))))
;
;         (let [results (zoxide-exec ["query" "--list" query])]
;           (if (= (length results) 0)
;               (vim.notify "Zoxide: No matches found" vim.log.levels.WARN)
;               (vim.ui.select 
;                 results 
;                 {:prompt (.. cd-cmd " to...")}
;                 (fn [choice]
;                   (when choice
;                     ;; --- THE FIX: vim.schedule ---
;                     ;; This ensures the picker is CLOSED and focus is BACK
;                     ;; in your workspace before the command fires.
;                     (vim.schedule 
;                       (fn []
;                         (vim.api.nvim_win_call target-win 
;                           #(do 
;                              (vim.cmd (.. cd-cmd " " (vim.fn.fnameescape choice)))
;                              ;; Force a notification so you can see it actually happened
;                              (vim.notify (.. "PWD -> " (vim.fn.getcwd target-win)) 
;                                          vim.log.levels.INFO {:title "Zoxide Jumped"})))
;                         (vim.system ["zoxide" "add" choice])))))))))))
;
; (fn M.setup []
;   (each [scope suffix (pairs {:global "" :tab "t" :window "w"})]
;     (vim.api.nvim_create_user_command 
;       (.. "Z" suffix)
;       (fn [opts] (M.z opts.args scope opts.bang))
;       {:nargs "*" :bang true})))
;
; (M.setup)
;
; M
