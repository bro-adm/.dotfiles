;; =============================================================================
;; OCTO.NVIM (Buffer-Centric / Magit-Style Workflow)
;; =============================================================================
(local (octo-ok octo) (pcall require :octo))

(when octo-ok
  (octo.setup 
    {;; 1. DISABLE PICKER OVERRIDE 
     ;; Setting to :default ensures Octo uses its own specialized buffers
     ;; instead of forcing everything into a Snacks/Telescope popup.
     :picker :snacks               
     
     ;; 2. REPO CONFIGURATION
     :default_remote ["upstream" "origin"] 
     :default_merge_method :squash
     :gh_cmd "gh"
     :enable_builtin true
     :mappings_disable_default false
     
     ;; 3. GUI / NEOVIDE ESTHETICS
     :colors {:white "#ffffff"
              :grey "#2A354C"
              :black "#000000"
              :red "#fdb8c0"
              :dark_red "#da3633"
              :green "#acf2bd"
              :dark_green "#238636"}
              
     ;; 4. DATA SORTING
     :pull_requests {:order_by {:field :CREATED_AT :direction :DESC}
                     :always_select_remote_on_create false}
     :issues {:order_by {:field :CREATED_AT :direction :DESC}}})

  ;; =============================================================================
  ;; KEYBINDINGS (<leader>g for GitHub/Git)
  ;; =============================================================================
  (let [map vim.keymap.set
        opts {:silent true}]
    
    ;; --- DASHBOARDS (Living Buffers) ---
    ;; Instead of a "Picker", these open a full buffer list you can inhabit.
    ;; Navigate with j/k, search with /, enter with <CR>.
    
    (map :n :<leader>gp "<CMD>Octo search is:pr is:open<CR>" 
         (vim.tbl_extend :force opts {:desc "PR Dashboard (Buffer-based)"}))
    
    (map :n :<leader>gi "<CMD>Octo search is:issue is:open<CR>" 
         (vim.tbl_extend :force opts {:desc "Issue Dashboard (Buffer-based)"}))

    ;; --- NOTIFICATIONS ---
    (map :n :<leader>gn "<CMD>Octo notification list<CR>" 
         (vim.tbl_extend :force opts {:desc "GitHub Notifications"}))

    ;; --- GLOBAL SEARCH ---
    ;; This opens an empty Search buffer where you can type your own filters.
    (map :n :<leader>gs "<CMD>Octo search <CR>"
         (vim.tbl_extend :force opts {:desc "Search GitHub (Global Buffer)"}))

    ;; --- THE "CLEAN" REVIEW (Optional Tip) ---
    ;; Use this when you are inside a PR buffer to see the diff properly.
    (map :n :<leader>gv "<CMD>Octo review start<CR>"
         (vim.tbl_extend :force opts {:desc "Start Review Session"}))))

;; =============================================================================
;; LAZYGIT.NVIM (Action-Based Git TUI)
;; =============================================================================
(local (lg-ok? lg) (pcall require :lazygit))

(when lg-ok?
  ;; 1. Global Variables (Customizing the Floating Window)
  ;; These use the vim.g (global) namespace as required by the plugin
  (set vim.g.lazygit_floating_window_winblend 0) ; No transparency for Neovide
  (set vim.g.lazygit_floating_window_scaling_factor 0.9) ; 90% screen width/height
  (set vim.g.lazygit_floating_window_border_chars ["╭" "─" "╮" "│" "╯" "─" "╰" "│"])
  
  ;; 2. Integration
  ;; Allows Lazygit to open files back in your current Neovim instance
  (set vim.g.lazygit_use_neovim_remote true)

  ;; 3. Custom Mappings for the LazyGit Buffer
  (let [map vim.keymap.set
        opts {:silent true}]

    (map :n :<leader>lg "<CMD>LazyGit<CR>" 
         (vim.tbl_extend :force opts {:desc "LazyGit Dashboard"}))
    
    ;; Open Lazygit for the current file only (Great for investigating specific bugs)
    (map :n :<leader>lf "<CMD>LazyGitCurrentFile<CR>" 
         (vim.tbl_extend :force opts {:desc "LazyGit (Current File Buffer)"}))
    
    ;; Open Lazygit Config (In case you need to tweak your TUI colors/keys)
    (map :n :<leader>lc "<CMD>LazyGitConfig<CR>" 
         (vim.tbl_extend :force opts {:desc "LazyGit Configuration"}))))

;; Force terminal colors to be "Deep" and "Vibrant" for Neovide
(let [colors { :0 "#1d2021" :1 "#fb4934" :2 "#b8bb26" :3 "#fabd2f"
               :4 "#83a598" :5 "#d3869b" :6 "#8ec07c" :7 "#ebdbb2"
               :8 "#928374" :9 "#fb4934" :10 "#b8bb26" :11 "#fabd2f"
               :12 "#83a598" :13 "#d3869b" :14 "#8ec07c" :15 "#fbf1c7"}]
  (each [i hex (pairs colors)]
    (set (. vim.g (.. "terminal_color_" i)) hex)))
