; {:libraries {:nvim true}}
; {:extra-globals "vim jit"}

{:lua-version :lua5.1 ; nvim uses LuaJIT
 :libraries {:nvim true} ; <- add this
 :macro-path "./?.fnl;./src/?.fnl"}

