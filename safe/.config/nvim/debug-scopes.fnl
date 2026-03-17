;; Debug script to output tab-buffers mapping to Conjure

(local tab-buffers _G.tab-buffers)
(local output [])

;; Build output as a table of strings
(table.insert output "=== TAB -> BUFFERS MAPPING ===")

(if (and tab-buffers (next tab-buffers))
    (each [tab-id buf-set (pairs tab-buffers)]
      (table.insert output (.. "Tab " tab-id ":"))
      (each [buf-id _ (pairs buf-set)]
        (when (vim.api.nvim_buf_is_valid buf-id)
          (let [bn (vim.api.nvim_buf_get_name buf-id)
                name (if (= bn "") "[No Name]" bn)]
            (table.insert output (.. "  - Buffer " buf-id ": " name))))))
    (table.insert output "  (empty)"))

(table.insert output "")
(table.insert output "=== BUFFERS -> TABS MAPPING ===")

(local buf-to-tabs {})
(when (and tab-buffers (next tab-buffers))
  (each [tab-id buf-set (pairs tab-buffers)]
    (each [buf-id _ (pairs buf-set)]
      (when (= nil (. buf-to-tabs buf-id))
        (tset buf-to-tabs buf-id []))
      (table.insert (. buf-to-tabs buf-id) tab-id))))

(if (next buf-to-tabs)
    (each [buf-id tab-list (pairs buf-to-tabs)]
      (when (vim.api.nvim_buf_is_valid buf-id)
        (let [bn (vim.api.nvim_buf_get_name buf-id)
              name (if (= bn "") "[No Name]" bn)
              tabs (table.concat tab-list ", ")]
          (table.insert output (.. "Buffer " buf-id " (" name "): tabs [" tabs "]")))))
    (table.insert output "  (empty)"))

(table.insert output "")
(table.insert output "=== CURRENT STATE ===")
(table.insert output (.. "Current tab: " (vim.api.nvim_get_current_tabpage)))
(table.insert output (.. "Current buffer: " (vim.api.nvim_get_current_buf)))

;; Return as a single string for Conjure to display
(table.concat output "\n")
