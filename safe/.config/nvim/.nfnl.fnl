(local core (require :nfnl.core))
(local config (require :nfnl.config))

(fn custom-path-mapper [path]
  ;; Use (. table :key) for safer lookup of keys with hyphens in Fennel
  (let [default-mapper (. (config.default) :fnl-path->lua-path)
        base-lua-path (default-mapper path)
        (new-path _) (string.gsub base-lua-path "/lua/plugins/" "/after/plugin/")]
    new-path))

;; Merge our custom mapper into the default configuration table
(core.merge
  (config.default)
  {:fnl-path->lua-path custom-path-mapper})
