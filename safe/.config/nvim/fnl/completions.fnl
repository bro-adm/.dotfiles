; ;; =====================================================================
; ;; Native Autocompletion (Neovim 0.11+)
; ;; =====================================================================
;
; ;; 1. Enable native auto-popup and modern UI
; (set vim.o.autocomplete true)
; (set vim.o.complete "o,.,w,b,u")
; (set vim.o.completeopt "fuzzy,menuone,noselect,popup")
; (set vim.o.pumheight 7)
; (set vim.o.pummaxwidth 80)
;
; ;; 2. Hide the annoying "match 1 of X" messages
; (vim.opt.shortmess:prepend "c")
;
; ;; 3. When LSP attaches, tell this buffer to ONLY use LSP for completion
; (vim.api.nvim_create_autocmd :LspAttach
;                              {:callback (fn [ev]
;                                           (vim.api.nvim_set_option_value :complete "o" {:buf ev.buf}))})

;; =====================================================================
;; Native Autocompletion (0.11.6 Stable - Fixed Version)
;; =====================================================================

;; 1. Setup the UI
(set vim.o.completeopt "menuone,noselect") 
(set vim.o.pumheight 10)
(vim.opt.shortmess:append "c")

;; Corrected 'complete' option:
;; . -> current buffer
;; w -> other windows
;; b -> other loaded buffers
;; u -> unloaded buffers
;; t -> tags
(set vim.o.complete ".,w,b,u,t")

;; 2. Enable LSP auto-triggering
(vim.api.nvim_create_autocmd :LspAttach
  {:callback (fn [args]
               (let [client (vim.lsp.get_client_by_id args.data.client_id)]
                 (when (and client (client:supports_method :textDocument/completion))
                   ;; This handles the 'LSP side' of things automatically
                   (vim.lsp.completion.enable true client.id args.buf {:autotrigger true}))))})

(vim.keymap.set :i :<Tab> (fn []
                            (if (vim.fn.pumvisible)
                                :<C-n>
                                :<Tab>))
                {:expr true})

(vim.keymap.set :i :<S-Tab> (fn []
                              (if (vim.fn.pumvisible)
                                  :<C-p>
                                  :<S-Tab>))
                {:expr true})

;; 1. Confirm selection with <CR> (Enter)
;; \13 is the decimal code for Carriage Return, \25 is <C-y>
(vim.keymap.set :i :<CR> 
  (fn []
    (if (> (vim.fn.pumvisible) 0)
        ;; If the menu is open...
        (let [complete_info (vim.fn.complete_info ["selected"])]
          (if (not= complete_info.selected -1)
              ;; If something IS selected (highlighted), confirm it (<C-y>)
              (vim.api.nvim_replace_termcodes :<C-y> true true true)
              ;; If nothing is selected, just do a normal Enter
              (vim.api.nvim_replace_termcodes :<CR> true true true)))
        ;; If menu is NOT open, just do a normal Enter
        (vim.api.nvim_replace_termcodes :<CR> true true true)))
  {:expr true :noremap true})

;; 2. Abort/Close menu with <C-CR> (Ctrl+Enter)
;; \05 is <C-e>
(vim.keymap.set :i :<C-CR> (fn []
                             (if (> (vim.fn.pumvisible) 0)
                                 (do (vim.api.nvim_replace_termcodes :<C-e> true true true))
                                 (do (vim.api.nvim_replace_termcodes :<C-CR> true true true))))
                {:expr true :noremap true})

(vim.keymap.set :n "<C-S-h>" vim.lsp.buf.hover {:desc "LSP Help/Hover"})

; ADD nvim blink pluggin for asynchronus complpetions optiosn from diff sources + fuzzy finding and all in one no config native snippets buffer lsp etc...
