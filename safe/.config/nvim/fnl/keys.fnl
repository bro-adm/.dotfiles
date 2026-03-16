(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

(local map (fn [mode binding action description]
  (vim.keymap.set mode binding action {:desc description :silent true :noremap true})))

(vim.keymap.set :n "<D-C-S-h>" ":leftabove vsplit<CR>" {:desc "Split Left"})
(vim.keymap.set :n "<D-C-S-l>" ":rightbelow vsplit<CR>" {:desc "Split Right"})
(vim.keymap.set :n "<D-C-S-h>" ":leftabove split<CR>" {:desc "Split Up"})
(vim.keymap.set :n "<D-C-S-h>" ":rightbelow split<CR>" {:desc "Split Down"})

(map [:n :v :x :o] :H "^" "Jump to start of line after blank chars") ; 0 goes to the start of line at 0
(map [:n :v :x :o] :L "g_" "Jump to end of line excluding blank characters") ; $ goes to the end of the line regardless of empty chars
(map [:n :v :x :o] :K :H "Jump to top of the visible screen") ; nvim still knows original H meaning (noremap)
(map [:n :v :x :o] :J :L "Jump to the bottom of visible screen") ; nvim still knowns original L meaning (noremap)
(map [:n :v :x :o] "<C-S-k>" "gg0" "Jump to start of File") ; absolute top at 0
(map [:n :v :x :o] "<C-S-j>" "G0" "Jump to bottom of File") ; absolute bottom at 0
(map :n "<S-CR>" :J "reverse enter -- join lines") ; nvim still knows original J meaning (noremap)

; The above do not effect D, C, S commands that all provide shortcuts for combo ops with $
; M fot middle remains unchaned

; D-C-= doesnt work :(
(map :n "<D-C-0>" "<C-w>=" "Splits Equal Size")
(map :n "<D-C-CR>" "<C-w>_<C-w>|" "Split Zoom")

(map :n "<D-C-t>" ":tabnew<CR>" "New Tab")
(map :n "<D-C-w>" ":ScopeClose<CR>" "Close Tab")
(map :n "<D-C-]>" ":tabnext<CR>" "Next Tab")
(map :n "<D-C-[>" ":tabprevious<CR>" "Previous Tab")



