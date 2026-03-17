;; ~/.config/nvim/after/plugin/config.fnl

; (local (snacks-ok snacks) (pcall require :snacks))
;
; (when snacks-ok
;   (snacks.setup {
;     :picker {
;       :enabled true
;       ;; 1. Force native behavior: jump to the window where the buffer already lives
;       :jump {:reuse_win true}
;       :previewers {
;         :diff {
;           :style "terminal" 
;           :cmd ["difft" "--color" "always" "--background" "dark" "--display" "inline"]
;         }
;         :git {
;           :args ["-c" "diff.external=difft"]
;         }
;       }
;       :sources {
;         :git_diff {
;           :preview "terminal"
;         }
;         ;; 2. Use the on_close hook to trigger your native scoping logic
;         ;; This ensures your local maps in init.lua update after the picker is gone
;         :files {:on_close #(_G.sync-buffer-visibility)}
;         :grep  {:on_close #(_G.sync-buffer-visibility)}
;       }
;     }
;   })
;
;   ;; Standard Keymaps
;   (vim.keymap.set :n :<leader>ff #(snacks.picker.files) {:desc "Find Files"})
;   (vim.keymap.set :n :<leader>fg #(snacks.picker.grep) {:desc "Grep Text"}))

; (local (snacks-ok snacks) (pcall require :snacks))
;
; (when snacks-ok
;   (snacks.setup {
;     :picker {
;       :enabled true
;
;       ;; 1. DEFINE CUSTOM ACTIONS
;       :actions {
;         ;; The "Smart Confirm" using your shared brain
;         :smart_confirm (fn [picker]
;                          (let [item (picker:current)]
;                            (if item
;                                (do
;                                  (picker:close)
;                                  ;; Passes buf-id if it exists, otherwise the file path
;                                  (_G.smart-open (or item.buf item.file item.text)))
;                                (picker:close))))
;
;         ;; Keep your "Pull Edit" if you want a specific bypass mapping
;         :pull_edit (fn [picker]
;                      (let [item (picker:current)]
;                        (when item
;                          (picker:close)
;                          (vim.cmd (.. "edit " (vim.fn.fnameescape (or item.file item.text)))))))}
;
;       ;; 2. BIND THE BRAIN TO KEYS
;       :win {
;         :input {
;           :keys {
;             ;; Standard Enter now uses the Priority Ladder
;             :<CR> {1 :smart_confirm :mode [:n :i] :desc "Smart Open"}
;             ;; Keep 'B' as a "Force Pull to Current Window"
;             :B {1 :pull_edit :mode [:n :i] :desc "Force Local Edit"}
;           }
;         }
;       }
;
;       ;; 3. PREVIEWERS & STYLE
;       :previewers {
;         :diff {
;           :style "terminal" 
;           :cmd ["difft" "--color" "always" "--background" "dark" "--display" "inline"]
;         }
;         :git { :args ["-c" "diff.external=difft"] }
;       }
;
;       ;; 4. LIBRARIAN SYNC
;       :sources {
;         :files {:on_close #(_G.sync-buffer-visibility)}
;         :grep  {:on_close #(_G.sync-buffer-visibility)}
;       }
;     }
;   })
;
;   ;; Standard Keymaps
;   (vim.keymap.set :n :<leader>ff #(snacks.picker.files) {:desc "Find Files"})
;   (vim.keymap.set :n :<leader>fg #(snacks.picker.grep) {:desc "Grep Text"}))

(local (snacks-ok snacks) (pcall require :snacks))

(when snacks-ok
  (snacks.setup 
    {:picker 
     {:enabled true
      
      ;; 1. Actions Library
      :actions
      {:smart_confirm (fn [picker]
                        ;; Check for multiple selections first
                        (let [selected (picker:selected)
                              items (if (and selected (> (length selected) 0))
                                        selected
                                        (let [current (picker:current)]
                                          (if current [current] [])))]
                          (picker:close)
                          ;; Open each selected item
                          (each [_ item (ipairs items)]
                            (_G.smart-open (or item.buf item.file item.text)))))

       :pull_edit (fn [picker]
                    (let [selected (picker:selected)
                          items (if (and selected (> (length selected) 0))
                                    selected
                                    (let [current (picker:current)]
                                      (if current [current] [])))]
                      (picker:close)
                      (each [_ item (ipairs items)]
                        (vim.cmd (.. "edit " (vim.fn.fnameescape (or item.file item.text)))))))}

      ;; 2. Source-Specific Overrides
      :sources 
      {:files {:on_close #(_G.sync-buffer-visibility)
               :win {:input {:keys {:<CR> {1 :smart_confirm :mode [:n :i]}}}}}
       :grep {:on_close #(_G.sync-buffer-visibility)
              :win {:input {:keys {:<CR> {1 :smart_confirm :mode [:n :i]}}}}}}

      ;; 3. Global Picker Window Keys
      :win 
      {:input 
       {:keys 
        {:B {1 :pull_edit :mode [:n :i] :desc "Force Local Edit"}}}}}})

  ;; 4. Keymaps (Inside the 'when' block)
  (vim.keymap.set :n :<leader>ff #(snacks.picker.files) {:desc "Find Files"})
  (vim.keymap.set :n :<leader>fg #(snacks.picker.grep) {:desc "Grep Text"}))
