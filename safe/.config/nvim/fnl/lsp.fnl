; lsp enable is not lsp init -> nvim will handle intiation on filetype events

(set vim.opt.keywordprg ":")

;; 2. The Native 0.12 Global Config
(vim.lsp.config "*" 
  {:on_attach (fn [client bufnr]
                (let [opts {:buffer bufnr :silent true :noremap true}]
                  ;; Now that the core 'K' logic has backed off, 
                  ;; your local mapping will reliably stick.
                  (vim.keymap.set :n :K :H (vim.tbl_extend :force opts {:desc "Top of Screen"}))
                  (vim.keymap.set :n :J :L (vim.tbl_extend :force opts {:desc "Bottom of Screen"}))
                  
                  ;; Relocate the docs
                  (vim.keymap.set :n :<leader>k vim.lsp.buf.hover opts)))})

(vim.lsp.config :fennel_ls
  {:cmd ["fennel-ls"]
   :filetypes ["fennel"]
   :root_markers ["flsproject.fnl" ".git"]
   :capabilities {:offsetEncoding ["utf-8" "utf-16"]}})

(vim.lsp.enable :fennel_ls)

(vim.lsp.config :gopls
  {:cmd ["gopls"]
   :filetypes ["go" "gomod" "gowork" "gotmpl"]
   :root_markers ["go.work" "go.mod" ".git"]
   :settings {:gopls {;; Adds placeholders to function completions
                      :usePlaceholders true
                      ;; Shows documentation on hover
                      :completeUnimported true
                      ;; Enables analysis for unused params, etc.
                      :analyses {:unusedparams true}
                      :staticcheck true}}})

(vim.lsp.enable :gopls)

