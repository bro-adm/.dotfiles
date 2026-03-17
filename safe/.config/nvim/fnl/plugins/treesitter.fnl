(local ts (require :nvim-treesitter))

;; 1. The Fix: Tell Neovim where the query files live
(vim.opt.runtimepath:append (.. (vim.fn.stdpath :data) :/site))

;; 2. Parser Management
(ts.setup {:ensure_installed [:lua :vim :query :fennel]
           :sync_install false
           :auto_install false})

;; Create the group and ensure it clears out old duplicates on reload
(local ts-group
       (vim.api.nvim_create_augroup :TreesitterHighlight {:clear true}))

;; 3. Autocommand to start the highlighting
(vim.api.nvim_create_autocmd :FileType
                             {:group ts-group
                              :callback (fn [args]
                                          (let [lang (vim.treesitter.language.get_lang args.match)]
                                            (when lang
                                              (pcall vim.treesitter.start
                                                     args.buf lang))))})
