(vim.notify "Fennel config has loaded successfully!" vim.log.levels.INFO)

;; 1. Register .lspy as a Clojure file so Conjure/LSP wake up
(vim.filetype.add {
  :extension {
    :lspy :clojure
  }
})

;; 2. Optional: Tell Conjure to prefer the nREPL client for these files
(set vim.g.conjure#filetype#clojure "conjure.client.clojure.nrepl")
(set vim.g.conjure#mapping#doc_word false)

(require :lsp)
(require :editor)
(require :tools)
(require :keys) ; could also be (require "keys")
; (require :completions)

(let [kubectl (require :kubectl)]
  ;; 1. Initialize the plugin
  (kubectl.setup
    {:log_level vim.log.levels.INFO
     :auto_refresh {:enabled true :interval 300}
     ;; If you want Logs/YAML to also be nearly full-screen within their floats:
     :float_size {:width 0.95 :height 0.85}})

  ;; 2. Map the toggle command to TAB mode
  ;; This ensures the main UI opens in a real buffer/tab instead of a popup
  (vim.keymap.set :n :<leader>k
                  #((. kubectl :toggle) {:tab true})
                  {:noremap true :silent true :desc "Kubectl (Tab Mode)"}))
