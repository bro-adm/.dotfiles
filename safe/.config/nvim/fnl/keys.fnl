(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(local map (fn [mode binding action description]
  (vim.keymap.set mode binding action {:desc description :silent true :noremap true})))

(vim.keymap.set :n "<D-C-S-h>" ":leftabove vsplit<CR>" {:desc "Split Left"})
(vim.keymap.set :n "<D-C-S-l>" ":rightbelow vsplit<CR>" {:desc "Split Right"})
(vim.keymap.set :n "<D-C-S-k>" ":leftabove split<CR>" {:desc "Split Up"})
(vim.keymap.set :n "<D-C-S-j>" ":rightbelow split<CR>" {:desc "Split Down"})
(map :n "<D-C-h>" "<C-w>h" "Window Left")
(map :n "<D-C-j>" "<C-w>j" "Window Down")
(map :n "<D-C-k>" "<C-w>k" "Window Up")
(map :n "<D-C-l>" "<C-w>l" "Window Right")

(map [:n :v :x :o] :H "^" "Jump to start of line after blank chars") ; 0 goes to the start of line at 0
(map [:n :v :x :o] :L "g_" "Jump to end of line excluding blank characters") ; $ goes to the end of the line regardless of empty chars
(map [:n :v :x :o] :K :H "Jump to top of the visible screen") ; nvim still knows original H meaning (noremap)
(map [:n :v :x :o] :J :L "Jump to the bottom of visible screen") ; nvim still knowns original L meaning (noremap)
(map [:n :v :x :o] "<C-S-k>" "gg0" "Jump to start of File") ; absolute top at 0
(map [:n :v :x :o] "<C-S-j>" "G0" "Jump to bottom of File") ; absolute bottom at 0

(map :n "<S-CR>" :J "reverse enter -- join lines") ; nvim still knows original J meaning (noremap)
(fn enter-move-mode []
  (let [buf (vim.api.nvim_get_current_buf)
        opts {:buffer buf :silent true :noremap true}]
    
    ;; 1. Define the Cleanup Function
    (fn exit-move-mode []
      (pcall #(vim.keymap.del :n :j {:buffer buf}))
      (pcall #(vim.keymap.del :n :k {:buffer buf}))
      (pcall #(vim.keymap.del :v :j {:buffer buf}))
      (pcall #(vim.keymap.del :v :k {:buffer buf}))
      (pcall #(vim.keymap.del :n "<Esc>" {:buffer buf}))
      (pcall #(vim.keymap.del :v "<Esc>" {:buffer buf}))
      (print "Exited Move Mode"))

    ;; 2. Set the "Sticky" Mappings
    ;; Normal Mode
    (vim.keymap.set :n :j ":m .+1<CR>==" opts)
    (vim.keymap.set :n :k ":m .-2<CR>==" opts)
    
    ;; Visual Mode
    (vim.keymap.set :v :j ":m '>+1<CR>gv=gv" opts)
    (vim.keymap.set :v :k ":m '<-2<CR>gv=gv" opts)

    ;; 3. Bind Escape to cleanup
    (vim.keymap.set [:n :v] "<Esc>" exit-move-mode opts)

    (print "-- MOVE MODE -- (j/k to move, Esc to exit)")))

;; 4. Trigger the mode
(map :n "<leader>m" enter-move-mode "Enter Sticky Move Mode")
(map :v "<leader>m" enter-move-mode "Enter Sticky Move Mode")

; The above do not effect D, C, S commands that all provide shortcuts for combo ops with $
; M fot middle remains unchaned

; D-C-= doesnt work :(
(map :n "<D-C-0>" "<C-w>=" "Splits Equal Size")
(map :n "<D-C-CR>" "<C-w>_<C-w>|" "Split Zoom")

(map :n "<D-C-t>" ":tabnew<CR>" "New Tab")
(map :n "<D-C-w>" "<C-w>q" "Close Window (not buffer)")
(map :n "<D-C-S-w>" ":ScopeClose<CR>" "Close Tab Scope")
(map :n "<D-C-]>" ":tabnext<CR>" "Next Tab")
(map :n "<D-C-[>" ":tabprevious<CR>" "Previous Tab")

(map :n "<D-C-x>" ":CloseWindow<CR>" "Close Window (Smart - with buffer)")

(map :n "<C-j>" ":bp<CR>" "Buffer Prev")
(map :n "<C-k>" ":bn<CR>" "Buffer Next")
(map :n "<C-x>" ":BufDelete<CR>" "Buffer Delete / Wipeout")
(map :n "<C-S-x>" ":BufDelete!<CR>" "Buffer Delete / Wipeout bang")

(fn copy-path-menu [scope]
  "scope can be 'current' or 'all'"
  (let [options ["Absolute Path" "Relative (CWD)" "Relative (Home)" "Filename Only"]
        lookup {"Absolute Path" ":p"
                "Relative (CWD)" ":."
                "Relative (Home)" ":~"
                "Filename Only" ":t"}
        prompt (if (= scope :all) "Copy ALL paths as:" "Copy CURRENT path as:")]

    (vim.ui.select options 
      {:prompt prompt}
      (fn [choice]
        (when choice
          (let [modifier (. lookup choice)
                ;; Logic to determine which buffer(s) to process
                targets (if (= scope :all)
                            (icollect [_ bufnr (ipairs (vim.api.nvim_list_bufs))]
                              (let [listed? (vim.api.nvim_get_option_value :buflisted {:buf bufnr})
                                    name (vim.api.nvim_buf_get_name bufnr)]
                                (if (and listed? (not= name "")) name)))
                            [(vim.api.nvim_buf_get_name 0)])
                
                ;; Format the paths using the modifier
                formatted-paths (icollect [_ name (ipairs targets)]
                                  (vim.fn.fnamemodify name modifier))
                
                content (table.concat formatted-paths "\n")]

            (vim.fn.setreg "+" content)
            (print (.. "Copied " (length formatted-paths) " path(s) to clipboard."))))))))

(map :n "<C-y>" #(copy-path-menu :current) "Copy Buffer Path")
(map :n "<C-S-y>" #(copy-path-menu :all) "Copy Tab Buffers Paths")

;; notable keymaps untoched:
;;   m -> mark then any symbol like 'ma' then it mark that curso point in 'a' and to go back is with `a
;;   q -> macro like 'qa' then '@a' replays that macro
;;   . -> replay action -> not all actions -> just stuff like i a cw ce cc dw dd d% (dL) ...
;;   z -> zz zt zb -> center cursor, top, bottom -> differnt then M to move the cursor to the middle of the screen, this moves the middle of the screen to the cursor

(fn jump-silo [dir]
  (let [start-buf (vim.api.nvim_get_current_buf)
        [jumps index] (vim.fn.getjumplist)
        len (length jumps)]
    (var total-steps 0)
    (var found-index -1)

    ;; 1. Look for the nearest jump in the current buffer
    (if (< dir 0)
        ;; BACKWARD
        (for [i (- index 1) 0 -1]
          (when (= found-index -1)
            (let [entry (. jumps (+ i 1))]
              (if (or (= entry.bufnr start-buf) (= entry.bufnr 0))
                  (set found-index i)
                  (set total-steps (+ total-steps 1))))))
        ;; FORWARD
        (for [i (+ index 1) (- len 1)]
          (when (= found-index -1)
            (let [entry (. jumps (+ i 1))]
              (if (or (= entry.bufnr start-buf) (= entry.bufnr 0))
                  (set found-index i)
                  (set total-steps (+ total-steps 1)))))))

    ;; 2. Execute the jump (Non-Recursive)
    (if (not= found-index -1)
        (let [steps (+ total-steps 1)
              code (if (< dir 0) :<C-o> :<C-i>)
              termcode (vim.api.nvim_replace_termcodes code true false true)]
          ;; Removed "zz" from the string here
          (vim.api.nvim_feedkeys (.. steps termcode) :nt false))
        (print "No more buffer-local jumps"))))

;; Mappings
(map :n "<C-o>" #(jump-silo -1) "Jump Back (Buffer Silo)")
(map :n "<C-i>" #(jump-silo 1)  "Jump Forward (Buffer Silo)")
(map :n "<C-S-o>" "<C-o>" "Native Jump Back (Window-wide)")
(map :n "<C-S-i>" "<C-i>" "Native Jump Forward (Window-wide)")

(map :n "<C-l>" ":nohlsearch<CR>" "Clear search highlights only")
(map :n "<C-S-l>" "<C-l>" "Native Redraw (Refresh Syntax)")

;; --- Task Control ---
(map :n "<C-t>" 
  (fn []
    (vim.cmd :nohlsearch)
    (vim.cmd :clearjumps)
    ;; vim.notify is the modern Lua-native way to handle messages
    (vim.notify "Task Reset" vim.log.levels.INFO {:title "Context Cleaned"}))
  "Task Reset (Clean Jumps & Search)")

;; :verbose cmap <CR>

;; 1. The Abbreviations (Keep these as they are)
; (local abbreviations 
;   {:q "BufDelete"
;    :Q "CloseWindow"
;    :wq "WriteBufDelete"
;    :wQ "WriteCloseWindow"
;    :tabclose "ScopeClose"})
;
; (each [lhs rhs (pairs abbreviations)]
;   (vim.cmd (.. "cabbrev " lhs " " rhs)))

(let [(ok? mk) (pcall require :mini.keymap)]
  (when ok?
    (mk.setup {})

    (local smart-tab
      {:condition (fn [] true)
       :action (fn []
                 (let [blink (require :blink.cmp)]
                   (if (blink.is_visible)
                       (blink.select_next)
                       (blink.show))))})

    ;; 1. Command Line Logic (Now Context-Aware)
    (local cmd-logic 
      {:condition (fn [] (= (vim.fn.getcmdtype) ":"))
       :action (fn []
                 (let [cmd (vim.fn.getcmdline)
                       ctrl-u (vim.api.nvim_replace_termcodes "<C-u>" true false true)
                       cr (vim.api.nvim_replace_termcodes "<CR>" true false true)
                       bang (or (cmd:match "!") "")
                       ;; --- CONTEXT CHECK ---
                       buf (vim.api.nvim_get_current_buf)
                       bt (vim.api.nvim_get_option_value :buftype {:buf buf})
                       win-cfg (vim.api.nvim_win_get_config 0)
                       is-float? (not= win-cfg.relative "")]
                   
                   ;; If we are in a float (Oil) or a special buffer (Help/Quickfix/etc),
                   ;; return 'false' so the alias is IGNORED and native :q runs.
                   (if (or (not= bt "") is-float?)
                       false 
                       (match (cmd:gsub "!" "")
                         :q (.. ctrl-u "BufDelete" bang cr)
                         :Q (.. ctrl-u "CloseWindow" bang cr)
                         :wq (.. ctrl-u "WriteBufDelete" bang cr)
                         :wQ (.. ctrl-u "WriteCloseWindow" bang cr)
                         :tabclose (.. ctrl-u "ScopeClose" bang cr)
                         (where _ (cmd:match "^[%d%-%+]+$")) (.. ctrl-u "mark '" cr ":" cmd cr)
                         _ false))))})

    ; (local cmd-logic 
    ;   {:condition (fn [] (= (vim.fn.getcmdtype) ":"))
    ;    :action (fn []
    ;              (let [cmd (vim.fn.getcmdline)
    ;                    ctrl-u (vim.api.nvim_replace_termcodes "<C-u>" true false true)
    ;                    cr (vim.api.nvim_replace_termcodes "<CR>" true false true)
    ;                    bang (or (cmd:match "!") "")]
    ;                (match (cmd:gsub "!" "")
    ;                  :q (.. ctrl-u "BufDelete" bang cr)
    ;                  :Q (.. ctrl-u "CloseWindow" bang cr)
    ;                  :wq (.. ctrl-u "WriteBufDelete" bang cr)
    ;                  :wQ (.. ctrl-u "WriteCloseWindow" bang cr)
    ;                  :tabclose (.. ctrl-u "ScopeClose" bang cr)
    ;                  (where _ (cmd:match "^[%d%-%+]+$")) (.. ctrl-u "mark '" cr ":" cmd cr)
    ;                  _ false)))})
    ;
    ;; --- Apply Multistep Mappings using BUILT-IN strings ---

    ;; COMMAND LINE: Accept completion first, then alias execution
    (mk.map_multistep :c "<CR>" [:blink_accept cmd-logic])
    (mk.map_multistep :c "<Tab>" [smart-tab])

    ;; INSERT ENTER: Accept completion OR Expand Pairs
    ;; Using built-in: 'blink_accept' and 'minipairs_cr'
    (mk.map_multistep :i "<CR>" [:blink_accept :minipairs_cr])

    ;; INSERT TAB: 1. Snippet -> 2. Blink Next -> 3. Blink Show -> 4. Brackets
    ;; Navigation in active vim.snippet session also requires Select-mode (s)
    ;; INSERT TAB: 1. Snippet -> 2. Smart Blink (Show if closed, Next if open) -> 3. Brackets
    (mk.map_multistep [:i :s] "<Tab>"
                  [:vimsnippet_next 
                   :blink_next 
                   :jump_after_close 
                   :jump_after_tsnode])

    ;; INSERT S-TAB: 1. Snippet Back -> 2. Blink Back -> 3. Brackets Back
    (mk.map_multistep [:i :s] "<S-Tab>" 
                      [:vimsnippet_prev :blink_prev :jump_before_open :jump_before_tsnode])

    ;; INSERT BACKSPACE: Pair delete + Hungry delete
    (mk.map_multistep :i "<BS>" [:minipairs_bs :hungry_bs])))

