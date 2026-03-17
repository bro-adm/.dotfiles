;; ~/.config/nvim/after/plugin/config.fnl

; ;; =============================================================================
; ;; 1. BUFFER_MANAGER (The "Oil" for Buffers)
; ;; =============================================================================
; (local (bm-ok bm) (pcall require :buffer_manager))
; (local (bmui-ok bmui) (pcall require :buffer_manager.ui))
;
; (when (and bm-ok bmui-ok)
;   (bm.setup {:short_file_names true
;              :use_shortcuts true
;              ;; Clean dismiss with q or Esc
;              :toggle_key_bindings ["q" "<ESC>"]})
;
;   ;; Mapping: '-' now opens the Buffer List
;   (vim.keymap.set :n :<C--> 
;                   bmui.toggle_quick_menu 
;                   {:desc "Buffer Manager (Oil-style)"}))

;; ~/.config/nvim/after/plugin/buffer-bouncer.fnl

(local M {})

(fn get-buf-info [buf]
  (let [name (vim.api.nvim_buf_get_name buf)
        disp-name (if (= name "") "[No Name]" (vim.fn.fnamemodify name ":~:."))
        listed? (vim.api.nvim_get_option_value :buflisted {:buf buf})
        modified? (vim.api.nvim_get_option_value :modified {:buf buf})
        ;; 'u' for unlisted (ls!), '+' for modified
        indicator (.. (if (not listed?) "u" " ")
                      (if modified? "+" " "))]
    (string.format "%3d %s %s" buf indicator disp-name)))

(fn M.open [all?]
  "all? true = include unlisted (ls!), all? false = listed only (ls)"
  (let [bufs (icollect [_ id (ipairs (vim.api.nvim_list_bufs))]
                (when (vim.api.nvim_buf_is_valid id)
                  (if (or all? (vim.api.nvim_get_option_value :buflisted {:buf id}))
                      id)))
        lines (icollect [_ id (ipairs bufs)] (get-buf-info id))
        bufnr (vim.api.nvim_create_buf false true)
        win-id (vim.api.nvim_open_win bufnr true 
                  {:relative :editor 
                   :row (math.floor (/ (- vim.o.lines 20) 2)) 
                   :col (math.floor (/ (- vim.o.columns 80) 2)) 
                   :width 80 :height (math.max 1 (math.min (length lines) 20)) 
                   :style :minimal :border :rounded})]

    (vim.api.nvim_buf_set_lines bufnr 0 -1 false lines)
    (vim.api.nvim_set_option_value :winblend 10 {:scope :local :win win-id})
    (vim.api.nvim_set_option_value :buftype :nofile {:buf bufnr})
    (vim.api.nvim_set_option_value :filetype :buffer-bouncer {:buf bufnr})

    ;; --- Logic Engine ---

    ;; ENTER: Use the Silo-Aware Smart-Open
    (vim.keymap.set :n :<CR> 
      (fn []
        (let [idx (vim.fn.line ".")
              target-id (. bufs idx)]
          (vim.api.nvim_win_close win-id true)
          ;; Use the global brain we built
          (_G.smart-open target-id))) 
      {:buffer bufnr :desc "Smart Open (Silo-Aware)"})

    ;; SHIFT-ENTER / B: Force Pull (Local Edit)
    (let [force-pull (fn []
                       (let [idx (vim.fn.line ".")
                             target-id (. bufs idx)]
                         (vim.api.nvim_win_close win-id true)
                         (vim.cmd (.. "buffer " target-id))))]
      (vim.keymap.set :n :<S-CR> force-pull {:buffer bufnr :desc "Force Local Pull"})
      (vim.keymap.set :n :B force-pull {:buffer bufnr :desc "Force Local Pull"}))

    ;; dd: Delete Buffer + Local Refresh
    (vim.keymap.set :n :dd 
      (fn []
        (let [idx (vim.fn.line ".")
              target-id (. bufs idx)]
          ;; Use your custom BufDelete command
          (vim.cmd (.. "BufDelete! " target-id))
          (vim.api.nvim_win_close win-id true)
          (M.open all?))) 
      {:buffer bufnr :desc "Nuke Buffer and Refresh"})

    (vim.keymap.set :n :q #(vim.api.nvim_win_close win-id true) {:buffer bufnr})
    (vim.keymap.set :n :<ESC> #(vim.api.nvim_win_close win-id true) {:buffer bufnr})))

;; --- Mappings ---
(vim.keymap.set :n :<C--> #(M.open false) {:desc "Buffer Bouncer (ls)"})
(vim.keymap.set :n :<C-_> #(M.open true) {:desc "Buffer Bouncer (ls!)"})

M

;; =============================================================================
;; 2. OIL.NVIM (File Explorer)
;; =============================================================================
(local (oil-ok oil) (pcall require :oil))

(when oil-ok
  (oil.setup {:float {:padding 2
                      :max_width 0.8
                      :max_height 0.8
                      :border :rounded
                      :win_options {:winblend 10}}
              :preview {:border :rounded}
              :view_options {:show_hidden true}
              :lsp_file_methods {:enabled true
                                 :autosave_changes true}
              :keymaps {;; Logic for 'q' and 'Esc' to close the float
                        :q :actions.close
                        :<ESC> :actions.close
                        :<C-p> :actions.preview
                        :<CR> :actions.select}})

  ;; Mapping: '_' (Shift + -) now opens the Oil File Explorer
  (vim.keymap.set :n "-" oil.open_float {:desc "open oil floating window"})
  (vim.keymap.set :n "_" (fn [] (oil.open_float (vim.fn.getcwd))) {:desc "Open Oil (CWD)"}))

