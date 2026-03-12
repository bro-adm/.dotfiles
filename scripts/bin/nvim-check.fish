#!/usr/bin/env fish

# Get top-level nvim PIDs only
set pids (pgrep -x nvim | while read p; ps -p $p -o args= | grep -qv -- "--embed"; and echo $p; end)

echo -e "PID\tDIRECTORY\t\t\tSTRUCTURE"
echo -e "---\t---------\t\t\t---------"

function walk_tree -a pid indent
    set children (pgrep -P $pid)
    for child in $children
        set child_path (ps -p $child -o comm=)
        set child_name (echo $child_path | sed 's|.*/||')
        
        set is_lsp 0

        # 1. Path Check: Is it running from the Mason directory?
        # (We use single quotes here too just to be safe, though not strictly needed)
        if ps -p $child -o args= | grep -q '/mason/'
            set is_lsp 1
        
        # 2. Name Check: Heuristics
        # FIX: Single quotes prevent Fish from thinking '$|' is a variable
        else if echo $child_name | grep -qE 'ls$|server|analyzer|daemon|clangd|node|rubocop'
            set is_lsp 1
        end

        # Render
        if test $is_lsp -eq 1
            # Green for confirmed LSPs
            echo -e "$indent └─ \033[1;32m$child_name\033[0m (PID: $child)"
        else
            echo -e "$indent └─ $child_name (PID: $child)"
        end
        
        walk_tree $child "  $indent"
    end
end

for pid in $pids
    set cwd (lsof -p $pid 2>/dev/null | awk '$4 == "cwd" {print $9; exit}')
    if test -z "$cwd"
        set cwd "???"
    end
    
    echo -e "[$pid]\t$cwd"
    walk_tree $pid ""
    echo "----------------------------------------------------------------------"
end
