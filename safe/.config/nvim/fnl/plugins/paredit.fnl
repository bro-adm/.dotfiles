(local paredit (require :nvim-paredit))

;; 1. Setup the plugin configuration
(paredit.setup
  {:filetypes ["fennel" "clojure" "scheme" "lisp" "janet"]
   :cursor_behaviour :auto
   :use_default_keys false
   :keys {;; --- STRUCTURAL ACTIONS (Leader) ---
          :<leader>s [paredit.api.slurp_forwards "Slurp forward"]
          :<leader>b [paredit.api.barf_forwards "Barf forward"]
          :<leader>S [paredit.api.slurp_backwards "Slurp backwards"]
          :<leader>B [paredit.api.barf_backwards "Barf backwards"]
          :<leader>> [paredit.api.drag_element_forwards "Drag element right"]
          :<leader>< [paredit.api.drag_element_backwards "Drag element left"]
          :<leader>r [paredit.api.raise_element "Raise element"]
          :<leader>u [paredit.unwrap.unwrap_form_under_cursor "Splice sexp"]

          ;; --- TEXT OBJECTS (Visual Mode Only) ---
          :af [paredit.api.select_around_form "Around form" {:mode [:v]}]
          :if [paredit.api.select_in_form "In form" {:mode [:v]}]
          :ae [paredit.api.select_element "Around element" {:mode [:v]}]
          :ie [paredit.api.select_element "Element" {:mode [:v]}]

          ;; --- NAVIGATION ---
          :W [paredit.api.move_to_next_element_head "Next element" {:mode [:n :x :v]}]
          :B [paredit.api.move_to_prev_element_head "Prev element" {:mode [:n :x :v]}]
          "(" [paredit.api.move_to_parent_form_start "Jump to parent start" {:mode [:n :x :v]}]
          ")" [paredit.api.move_to_parent_form_end "Jump to parent end" {:mode [:n :x :v]}]}})

;; 2. MANUAL OPERATOR MAPPINGS (The "dif/daf" fix)
;; We map these explicitly to ensure 'd', 'c', and 'y' work without 
;; needing to enter visual mode first.
(let [api (require :nvim-paredit.api)
      opts {:desc "Paredit Textobject"}]
  (vim.keymap.set :o :if api.select_in_form opts)
  (vim.keymap.set :o :af api.select_around_form opts)
  (vim.keymap.set :o :ie api.select_element opts)
  (vim.keymap.set :o :ae api.select_element opts))
