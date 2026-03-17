(set vim.opt.clipboard :unnamedplus)

;; Use pcall to ensure your config doesn't crash if the plugin is missing
(let [(ok? pairs) (pcall require :mini.pairs)]
  (when ok?
    ;; Basic setup with default pairs: (), [], {}, "", '', ``
    (pairs.setup {})
    ))


;; Usage: saiw) (add), sd" (delete), sr") (replace)
(let [(ok? surround) (pcall require :mini.surround)]
  (when ok?
    (surround.setup {:mappings {:add "sa"
                                :delete "sd"
                                :find ""
                                :find_left ""
                                :highlight ""
                                :replace "sr"
                                :update_n_lines ""}})))

;; Usage: ci( (change inside parens), da[ (delete around brackets)
;; It also adds 'next' and 'last' targets: cin( (change inside NEXT parens)
(let [(ok? ai) (pcall require :mini.ai)]
  (when ok?
    (let [spec_treesitter ai.gen_spec.treesitter]
      (ai.setup 
        {:n_lines 500
         :search_method :cover_or_next
         :custom_textobjects 
         {;; Function: vif / vaf
          :f (spec_treesitter {:a "@function.outer" :i "@function.inner"})
          ;; Parameter: via / vaa
          :a (spec_treesitter {:a "@parameter.outer" :i "@parameter.inner"})
          ;; Class/Struct: vic / vac
          :c (spec_treesitter {:a "@class.outer" :i "@class.inner"})
          ;; Call: viF / vaF
          :F (spec_treesitter {:a "@call.outer" :i "@call.inner"})
          ;; Objects (Block/Condition/Loop): vio / vao
          :o (spec_treesitter {:a ["@block.outer" "@conditional.outer" "@loop.outer"]
                               :i ["@block.inner" "@conditional.inner" "@loop.inner"]})
          ;; Assignment: vii / vai
          :i (spec_treesitter {:a "@assignment.outer" :i "@assignment.inner"})}
         :mappings {:around_next :an
                    :inside_next :in
                    :around_last :al
                    :inside_last :il}}))))

; (let [(ok? blink) (pcall require :blink.cmp)]
;   (when ok?
;     (blink.setup {;; 'default' is the preset for Neovim's native snippets
;                   :snippets {:preset :default}
;
;                   :sources {:default [:lsp :path :snippets :buffer]}
;
;                   ;; Use strings for keys that contain special characters
;                   :keymap {:preset :default
;                            :keymap_edit_window {"<Tab>" [:snippet_forward :fallback]
;                                                 "<S-Tab>" [:snippet_backward :fallback]}}})))

; (let [(ok? blink) (pcall require :blink.cmp)]
;   (when ok?
;     (blink.setup {;; Force Lua for fuzzy matching
;                   :fuzzy {:implementation :lua}
;                   ;; Use Neovim 0.10+ native snippets
;                   :snippets {:preset :default}
;                   :sources {:default [:lsp :path :snippets :buffer]}
;                   :completion {:accept {:auto_brackets {:enabled false}}
;                                :ghost_text {:enabled false}
;                                ;; FIXED: selection must be a table
;                                :list {:selection {:preselect false}} 
;                                :menu {:auto_show (fn [ctx] (not= ctx.mode :cmdline))}}
;                   ;; Disable Blink's internal keymaps
;                   :keymap {:preset :none}})))
;

(let [(ok? blink) (pcall require :blink.cmp)]
  (when ok?
    (blink.setup {
                  :fuzzy {:implementation :lua}
                  :snippets {:preset :default}
                  :sources {:default [:lsp :path :snippets :buffer]}
                  :completion {:accept {:auto_brackets {:enabled false}}
                               :ghost_text {:enabled false}
                               ;; 'manual' is a string in the latest blink, 
                               ;; or {:preselect false} in older ones. 
                               :list {:selection {:preselect false :auto_insert false}}
                               :menu {:auto_show true}}
                  :keymap {:preset :none}})))
