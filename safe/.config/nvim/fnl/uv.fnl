; (local uv vim.uv)
; (local api vim.api)
;
; (local MAX_LINES 5000)
; (local BACKPRESSURE_LIMIT 2000)
;
; (fn strip-ansi [str]
;   (str:gsub "\27%[[0-9;]*[mK]" ""))
;
; (fn stream-kube-logs [pod-name]
;   (let [buf (api.nvim_create_buf false true)
;         stdout (uv.new_pipe false)
;         stderr (uv.new_pipe false)
;         state {:handle nil 
;                :active true 
;                :updating false 
;                :is_paused false
;                :acc "" 
;                :pending_lines [] 
;                :buf_id buf}]
;
;     (api.nvim_buf_set_name buf (.. "k8s://" pod-name))
;     (api.nvim_set_option_value :buftype :nofile {:buf buf})
;     (api.nvim_set_option_value :filetype :log {:buf buf})
;     (api.nvim_set_option_value :undolevels -1 {:buf buf})
;
;     (api.nvim_command "vsplit")
;     (api.nvim_set_current_buf buf)
;
;     ;; --- FORWARD DECLARATION ---
;     ;; We declare read-cb as a var so flush-to-buffer can see it.
;     (var read-cb nil)
;
;     (fn cleanup []
;       (when state.active
;         (set state.active false)
;         (pcall (fn []
;                  (when (and state.handle (not (state.handle:is_closing)))
;                    (state.handle:kill 15)
;                    (state.handle:close))
;                  (if (not (stdout:is_closing)) (stdout:close))
;                  (if (not (stderr:is_closing)) (stderr:close))))))
;
;     (api.nvim_create_autocmd :BufWipeout {:buffer buf :callback cleanup})
;
;     ;; --- THE SNAPSHOT WRITER ---
;     (fn flush-to-buffer []
;       (if (and state.active (api.nvim_buf_is_valid state.buf_id))
;           (let [lines state.pending_lines
;                 win (vim.fn.bufwinid state.buf_id)]
;             (set state.pending_lines [])
;
;             (pcall (fn []
;                      (api.nvim_buf_set_lines state.buf_id -1 -1 false lines)
;                      (let [count (api.nvim_buf_line_count state.buf_id)]
;                        (when (> count MAX_LINES)
;                          (api.nvim_buf_set_lines state.buf_id 0 (- count MAX_LINES) false [])))
;
;                      (when (and win (not= win -1))
;                        (api.nvim_win_set_cursor win [(api.nvim_buf_line_count state.buf_id) 0]))))
;
;             (set state.updating false)
;
;             ;; Resume the UV pipe if backpressure is gone
;             (when (and state.is_paused (< (length state.pending_lines) 100))
;               (set state.is_paused false)
;               (uv.read_start stdout read-cb)))
;           (set state.updating false)))
;
;     ;; --- THE UV CALLBACK ---
;     (set read-cb (fn [err data]
;       (if (and (not err) data)
;           (let [clean (strip-ansi (data:gsub "\r" ""))
;                 full (.. state.acc clean)
;                 lines (vim.split full "\n" {:plain true})]
;             (set state.acc (table.remove lines))
;             (each [_ l (ipairs lines)]
;               (table.insert state.pending_lines l))
;
;             (when (> (length state.pending_lines) BACKPRESSURE_LIMIT)
;               (set state.is_paused true)
;               (uv.read_stop stdout))
;
;             (when (not state.updating)
;               (set state.updating true)
;               (vim.schedule flush-to-buffer)))
;           (cleanup))))
;
;     ;; --- START ---
;     (set state.handle 
;          (uv.spawn "oc" {:args ["logs" "-f" pod-name] :stdio [nil stdout stderr]}
;                    (fn [code signal] (cleanup))))
;
;     (uv.read_start stdout read-cb)
;     state.handle))

(local uv vim.uv)
(local api vim.api)

;; --- CONFIGURATION ---
(local MAX_LINES 5000)
(local TRIM_THRESHOLD 5500)    ;; Only trim when we hit this (Batching)
(local BACKPRESSURE_LIMIT 2000) ;; Pause 'oc' if Lua queue hits this

(fn strip-ansi [str]
  (str:gsub "\27%[[0-9;]*[mK]" ""))

(fn stream-kube-logs [pod-name]
  (let [buf (api.nvim_create_buf false true)
        stdout (uv.new_pipe false)
        stderr (uv.new_pipe false)
        ;; State machine for thread-safe coordination
        state {:handle nil 
               :active true 
               :updating false  ;; The Mutex Lock
               :is_paused false ;; Backpressure state
               :acc "" 
               :pending_lines [] 
               :buf_id buf}]
    
    ;; 1. Buffer Initialization
    (api.nvim_buf_set_name buf (.. "k8s://" pod-name))
    (api.nvim_set_option_value :buftype :nofile {:buf buf})
    (api.nvim_set_option_value :filetype :log {:buf buf})
    ;; CRITICAL: Disable undo to prevent memory bloat and "12k limit" freezes
    (api.nvim_set_option_value :undolevels -1 {:buf buf})
    
    (api.nvim_command "vsplit")
    (api.nvim_set_current_buf buf)

    ;; Forward declare to allow mutual recursion between UV and UI
    (var read-cb nil)

    ;; 2. Resource Cleanup
    (fn cleanup [reason]
      (when state.active
        (set state.active false)
        (pcall (fn []
                 (when (and state.handle (not (state.handle:is_closing)))
                   (state.handle:kill 15)
                   (state.handle:close))
                 (if (not (stdout:is_closing)) (stdout:close))
                 (if (not (stderr:is_closing)) (stderr:close))))
        (when reason (print (.. "Log Stream: " reason " [" pod-name "]")))))

    (api.nvim_create_autocmd :BufWipeout 
      {:buffer buf :callback (fn [] (cleanup "Buffer wiped"))})

    ;; 3. THE CONSUMER: Writes to the Buffer (Runs on Main Thread)
    (fn flush-to-buffer []
      (if (and state.active (api.nvim_buf_is_valid state.buf_id))
          (let [lines state.pending_lines
                win (vim.fn.bufwinid state.buf_id)]
            ;; Clear the queue immediately to free Lua memory
            (set state.pending_lines [])
            
            (pcall (fn []
                     ;; APPEND: Low-level C call (Fast)
                     (api.nvim_buf_set_lines state.buf_id -1 -1 false lines)
                     
                     ;; BATCHED WINDOWING: Only shift memory when threshold is hit
                     (let [count (api.nvim_buf_line_count state.buf_id)]
                       (when (> count TRIM_THRESHOLD)
                         (let [to-remove (- count MAX_LINES)]
                           (api.nvim_buf_set_lines state.buf_id 0 to-remove false []))))
                     
                     ;; STICKY SCROLL: Jump to bottom
                     (when (and win (not= win -1))
                       (let [last (api.nvim_buf_line_count state.buf_id)]
                         (api.nvim_win_set_cursor win [last 0])))))

            ;; RELEASE LOCK
            (set state.updating false)
            
            ;; RESUME PIPE: If backpressure was active and queue is now small
            (when (and state.is_paused (< (length state.pending_lines) 100))
              (set state.is_paused false)
              (uv.read_start stdout read-cb)))
          ;; Safety release if buffer was lost
          (set state.updating false)))

    ;; 4. THE PRODUCER: Reads from UV Pipe (Runs on Background Thread)
    (set read-cb (fn [err data]
      (if (and (not err) data)
          (let [clean (strip-ansi (data:gsub "\r" ""))
                full (.. state.acc clean)
                lines (vim.split full "\n" {:plain true})]
            ;; Handle partial lines
            (set state.acc (table.remove lines))
            (each [_ l (ipairs lines)]
              (table.insert state.pending_lines l))
            
            ;; CHECK BACKPRESSURE
            (when (> (length state.pending_lines) BACKPRESSURE_LIMIT)
              (set state.is_paused true)
              (uv.read_stop stdout))

            ;; TRIGGER UI UPDATE: Only if a schedule isn't already pending
            (when (not state.updating)
              (set state.updating true)
              (vim.schedule flush-to-buffer)))
          (cleanup (or err "EOF reached")))))

    ;; 5. START PROCESS
    (set state.handle 
         (uv.spawn "oc" {:args ["logs" "-f" pod-name] :stdio [nil stdout stderr]}
                   (fn [code signal] (cleanup (.. "Process exited: " code)))))

    (uv.read_start stdout read-cb)
    
    ;; Return the handle from the let block
    state.handle))

;; Usage: (stream-kube-logs "your-pod-name")

;; Usage: Change "my-pod-name" to a real pod
(let [handle (stream-kube-logs "opendatahub-operator-controller-manager-54c4d48d5d-cxxxs")]
  (print (.. "Started streaming PID: " (tostring handle))))

