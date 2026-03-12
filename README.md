# .dotfiles

Personal dotfiles managed with GNU Stow for macOS.

## Structure

This repository organizes dotfiles into three categories:

- **`safe/`** - Configuration files that can be safely stowed with directory folding
- **`unsafe/`** - Sensitive configurations stowed with `--no-folding` to prevent accidental overwrites
- **`scripts/`** - User scripts and binaries deployed to `~/bin`

## Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/)
- macOS (Darwin)

Install Stow via Homebrew:
```bash
brew install stow
```

## Usage

### Quick Start

```bash
# Show all available commands
make help

# Stow all packages
make stow

# Remove all stowed packages
make unstow

# Adopt existing local files
make adopt
```

### Available Commands

| Command | Description |
|---------|-------------|
| `make help` | Show help message with all available commands |
| `make stow` | Stow all packages (safe, unsafe, and scripts) |
| `make stow-safe` | Stow only safe packages |
| `make stow-unsafe` | Stow only unsafe packages (with no-folding) |
| `make stow-scripts` | Stow user scripts to ~/bin |
| `make unstow` | Remove all stowed packages |
| `make adopt` | Adopt existing local files into dotfiles |

### What is Stow?

[GNU Stow](https://www.gnu.org/software/stow/) is a symlink farm manager that creates symlinks from your home directory to files in this repository. This allows you to:

- Keep all dotfiles in version control
- Easily deploy configurations across multiple machines
- Update configurations by editing files in this repository

### Adopting Existing Files

If you have existing dotfiles in your home directory, use `make adopt` to move them into this repository while creating the appropriate symlinks.

## Configuration Highlights

### Included Configurations

- **Ghostty** - Terminal emulator configuration
- **Neovim** - Editor configuration with plugins
- **Aerospace** - Window manager configuration
- **Oh My Posh** - Shell prompt configuration
- **Git** - Version control settings
- **Nix Darwin** - System configuration
- **LSD** - Modern `ls` replacement configuration
- **Zsh** - Shell configuration with vi mode

### Custom Scripts

Scripts in `scripts/bin/` are automatically made executable and linked to `~/bin`, including:
- `kubetoggle` - Kubernetes context/namespace switching utility

## Development

This repository uses:
- Nix Darwin for system configuration
- Home Manager for user environment
- direnv with Nix flakes for project-specific environments

## License

Personal configuration files - use at your own discretion.

## TODO

- Atuin does not have a jump to dir logic on exec !!!
- Atuin workspace not working yet for me
- Atuin no shell-up binding
- Aerospace no keybind to contrinously move between workspaces/desktops - like long option+shift instead of short press...
- nvim tabs navigation incosistent with temrinla splits and aerospce panels navigation
- nvim buffers scope plugin has issue with leaving buffer on inital tab - all other moves are good...

## Dev


| Feature | **OS Layer** (Aerospace) | **Editor Layer** (Neovim) | **Terminal Layer** (Ghostty) |
| :--- | :--- | :--- | :--- |
| **Management Key** | **Option** (`⌥`) | **Ctrl** (`⌃`) | **Cmd + Option** (`⌘⌥`) |
| **Control Key** | **Ctrl** (`⌃`) | **Cmd** (`⌘`) | **Ctrl** (`⌃`) |
| | | | |
| **Navigate**<br>*(Focus Split/Win)* | `⌥` + `hjkl` | `⌃` + `hjkl` | `⌘⌥` + `hjkl` |
| **Move / Swap**<br>*(Swap Split/Win)* | `⌥⌃` + `hjkl` | `⌃⌘` + `hjkl` | `⌘⌥⌃` + `hjkl` |
| **Create Split**<br>*(Directional)* | *N/A* | *N/A (Use Edit)* | `⌘⌥⇧` + `hjkl` |
| | | | |
| **Cycle Container**<br>*(Next/Prev Tab/WS)* | `⌥⇧` + `hl` | `⌃⇧` + `hl` *(Tabs)* | `⌘⇧` + `hl` *(Tabs)* |
| **Cycle Items**<br>*(Next/Prev Buffer)* | *N/A* | `⌃⇧` + `jk` *(Buffers)* | *N/A* |
| **Move Obj. to Cont.**<br>*(Send to Tab/WS)* | `⌥⌃⇧` + `hl` | `⌃⌘⇧` + `hl` | *N/A* |
| | | | |
| **Reorder Container**<br>*(Move Tab/WS itself)*| **Hyper** + `hl` | **Hyper** + `hl` | **Hyper** + `hl` |



----------------------


option + cmd + number                           ->              mac -> emojis / history / files
option + cmd + symbols                          ->              mac -> do-in-a-app
option + ctrl + letter                          ->              mac -> move-to app
option + letter                                 ->              mac -> move-to app
option + number                                 ->              mac -> move-to workspace
option + shift + number                         ->              app -> move-to workspace
option + [] + ?shift                            ->              workspace -> move-to app
option + ctrl + [] + ?shift                     ->              workspace -> move app
option + cmd + [] + ?shift                      ->              app -> move-to split
option + cmd + ctrl + [] + ?shift               ->              app -> create split
option + cmd + enter                            ->              split -> zoom
option + cmd + shift + enter                    ->              app -> zoom

cmd + shift + []                                ->              app -> move-to tab
cmd + []                                        ->              app -> undo / redo

statements:
- using nvim tabs is okay but removes the option to use native tabs for terminal which is okay becuase worksapce naviation equals terminal tabs without quick-jump or overview (cmd + number | cmd + shift + \)
  using nvim tabs actually gives us something of organization and buffer scopes instead of endless nvim sessions for both same-project&logic-grouping & diff-projects-groupings.
  terminal native macos tabs collide with workspaces moves (macos issue) - so usign app insatnces instead of tabs also disregards that workflow
- using [] + ?shift as up/down/left/right limits usecases of shift additions
- ctrl logic should be kept mac wide for only terminal term-x256-color operations
- ctrl + shift should be used for shell specific keybinds e.g. fish or zsh extensions
- trying to avvoid arrow keys is good + hjkl vim sucks)
- hjkl sucks -> having letterable meaning in keybinds is super important
- macos uses cmd+tab and cmd+shift+[] and cmd+[] for known stuff so we should use it as well for the same stuff becuase that is not changable and allows seemless work betwene terminal and browser for example isntead of confusingdifferent rules
- I know get hjkl and i see its resembles mindbinding wise to awsd so it will do, having letter meaning is important but having mind peace is more.

issues:
- nvim splits + terminal splits can be managed via same keybinds BUT splits toogle zoom cannot becuase of toggle fullscreen -> remove toggle full screen (keep it only globe+f)
- no way to use logical keybinds for vsplit and split in nvim in terminal becuase option+cmd+ctrl+[]+?shift already is used for terminla level splits -> same issue as toggle zoom on splits
- no app levels move splits around app like move apps inside a worksapce -> and if was no conceptually correct keybind for it ()

inconsistencies:
- there is move app inside a worspace via [] + ?shift but none for move app between workspaces via [] -> instead u need to know the number -> can map that to option + \ + ?shift
- nvim does not regard [] and [[]] and } {{}} the same as me seeing them as perfer next+prev with shift for lines... (hjkl sucks)
- when u nvim (app) in a server - u lose all kkp for splits logic and more -> need to investigate how to make ssh connection be via sockat side session and translate...


cmd + ctrl -> unsiuable logically - not for creating or moving around nvim splits -> jsuit wouldnt make sense accoding to the fact that we already map option+cmd+ctrl... for creatiion of splits and so and so ... -> the issues of shift being used for just up and down as opposed to being the layer split for app and inner app like temrinla and nvim.... and what about the fact that we are naviagteing inner splits with option+cmd+[]... just becasue its faster when movign around workspace tabs with option+[] and the zoom logic with option+cmd but then if u think from the other side of things or just look at a single app then cmd+shift+tab is tabs and cmd+[] would be for inner splits... that can make sense but lets stick with the first option because in browsers for exmaple by default cmd+[] is undo redo prev next page so we dont want to confuse... 

FIX

cmd + ctrl + number                             ->              mac -> emojis / history / files         ->          done
cmd + ctrl + symbols                            ->              mac -> do-in-a-app                      ->          done
cmd + ctrl + letter                             ->              mac -> move-to management app           ->          done
option + letter/key + ?shift                    ->              mac -> move-to app                      ->          done

option + number                                 ->              mac -> move-to workspace                ->          done
option + shift + h/l                            ->              mac -> move-to workspace                ->          done

option + ctrl + number                          ->              app -> move-to workspace                ->          done
option + ctrl + shift + h/l                     ->              app -> move-to workspace                ->          done

option + hjkl                                   ->              workspace -> move-to app                ->          done
option + ctrl + hjkl                            ->              workspace -> move app                   ->          done

option + cmd + hjkl                             ->              app -> move-to split                    ->          done
option + cmd + shift + hjkl                     ->              app -> create split                     ->          done

cmd + ctrl + hjkl                               ->              inner-app -> move-to split              ->          done
cmd + ctrl + shift + hjkl                       ->              inner-app -> create split               ->          done

once ghostyy supports `performable` with inital check via kkp for inner app and shift to run regardless on ghosty layer -> 
option+cmd+hjkl (navigation) would jsut work becuase splits would look corect and no need for shift layer
option+cmd+shift+hjkl (creation) would not work !!! -> SO WHAT IS NOW IS GOOD

cmd + ctrl + enter                              ->              inner-app -> zoom split                 ->          TODO
option + cmd + enter                            ->              app -> zoom split                       ->          done

ctrl is used inside the terminal itself to represent the app (regardless ofcourse from the shell and so and so..)
meaning we shouldnt uise it like with option + ctrl for move logic

once ghsoty supports perfrormable with inital check via kkp for inner app performabilty and shift to directly run on terminal emulator regardless ->
cmd + option + ctrl + hjkl + ?shift ==== move splits around -> moving splits is all about the layout avaible so it makes sense.

cmd + ctrl + shift + []                         ->              inner-app -> move-to tab                ->          done
cmd + ctrl + []                                 ->              inner-app-inner-surface -> move-to view ->          done

cmd + shift + []                                ->              app -> move-to tab                      ->          never - removed do to incosistency with aerospce as ghostty tabs are native macos tabs and tehy are probalemtic with every tiling mnager
---------------- aerospace tiling of instance is like tabs for a worksapce without quick jump or tab overview ---------------- 
cmd + []                                        ->              app -> undo / redo                      ->          never -> command+z for app level and in inner-app level we can would want it for buffer navigations with ofcourse ctrl addition so no need for that
cmd + shift + \                                 ->              app -> tab overview                     ->          never -> the only missing thiungs when not using ghosty tabs becuase they do support it
option + cmd + shift + \                        ->              workspace -> same app instances overview->          dependent -> aerospace
option + \                                      ->              workspace -> apps overview              ->          dependent -> aerospace
option + shift + \                              ->              macos -> workspaces overview            ->          dependent -> aerospace

---------------------

NVIM :

- b beggingni of prev word
- w beggning of next word - same as ctrl+space
- e end of next word
- f+char find next occurance of char in same line
- g_ like $ move to end of line (A moves to end of line and enter inser tmode on append) 
- ^ like 0 move to start of line
- zz recenter screeen accordign to cursor
- S == dd + insert mode on same line

useless binds:
- L - goes to last line in seen screen - not of file like G
- H - does hte same concept of L but for top screen line
- M - does the saem but to the middle of the screen
- J - removes teh enter between current line and the line under it 

ctrl + hjkl -> movemonet between splits
ctrl + [] -> movemtn between tabs

ctrl + shift + hjkl -> move splits inside tab
ctrl + shift + [] -> move tabs around
ctrl + shift + cmd + [] -> move buffers between tabs

ctrl + cmd + hjkl -> create splits
ctrl + cmd + t / w -> create / close tab

ctrl + enter -> toggle split zoom 

MAKE AEROSPACE WOEKSAPACE CYLE WITH [] INSTEAD OF SHIFT - MAKE IT CONSISTENT WITH NVIM LOGIC


OR 

ctrl + cmd + shift + [] -> move tabs
ctrl + cmd + [] -> move buffers between tabs
ctrl + cmd + shift + hjkl -> move splits in tab

ctrl + cmd + hjkl -> create splits in tab

ctrl + hjkl -> move-to split
ctrl + shift + [] -> move-to tab
ctrl + [] -> move-to next buffer

OR

ctrl + [] -> cycle buffers
ctrl + shift + [] -> move buffer to next tab

ctrl + cmd + [] -> cycle tabs
ctrl + cmd + shift + [] -> move tabs

ctrl + hjkl -> move-to split
ctrl + shift + hjkl -> move splits inside tab
ctrl + cmd + hjkl -> create split

ctrl + cmd + t / w -> create / close tab
ctrl + cmd + enter -> toggle split zoom 

ctrl + cmd + shift + hjkl -> STILL AVAILABLE


nvim has tabs, splits and buffers - that is one more thing then aerospace that manages tabs and splits and but no app (split) creation

meaning we can make nvim create splits with ctrl + -\ for hosrizontal and vertical - BUT TAHT DOENST HAVE DIRECTION

ctrl + [] -> cycle buffers
ctrl + shift + [] -> cycle tabs

ctrl + cmd + [] -> move buff to tab
ctrl + cmd + shift + [] -> move tab

ctrl + hjkl -> move-to split
ctrl + shift + hjkl -> 
ctrl + cmd + hjkl -> move split
ctrl + cmd + shift + hjkl -> create split

hjkl is inner tab stuff
[] is cycable stuff

cmd - is app layer of nvim creation and move of its objects
shift - is for inner tab movement


OR

option + shift + hl -> cycle worksapces

option + ctrl + shift + hl -> move app to another worksapce
NADA -> move worksapce

option + hjkl -> move-to app (split in worksapce)
option + ctrl + hjkl > move apps inside workspace

-------

ctrl + shift + jk -> cycle buffers
ctrl + shift + hl -> cycle tabs -> like option + shift + hl for worksapce navigation

ctrl + cmd + shift + hl -> move buf to tab -> liek option + ctrl + shift + hl to move app between workspaces
NADA -> move tab

ctrl + hjkl -> move-to splits -> like option + hjkl to navigate inside workspace
ctrl + cmd + hjkl -> move split -> like option + ctrl + hjkl to move app (buffer+split) inside worksapce (tab)

missing create split -> but not really needed becuase we can jsut launch it with a eidt file combo via ctrl+cmd+n -> no direction on create which is fine

--------

cmd + option + hjkl -> move-to splits inside terminal emulator
cmd + option + shift + hjkl -> create splits inside terminla emulator

cmd + shift + hl -> cycle tabs inside terminal emulator -> instead of the normal cmd+shift+[] becuase we trying to be consistent.
cmd + shift + jk -> NADA

here creation of splits is a must becuase cant just do combo with create...
no movement of splits

wihtout using [] u can only maximze to a certain level the keybinds and each layer which we have three requires a makanagement key + a control key
If you make ctrl the management key for nvim and then cmd the cotnrl key 
and for aerospace option the managemnt and ctrl the contrl then at least u leave the cmd + option combo for terminla emulator layer.

if we would hav emade command the ctrl key for eahc managment then no combo left for terminlal emulator and then cmd itself is limited as its seen as having immutable keybinds system wide and even if it wasent it wouldnt have a control key for its level.

Thten u look at hyper key and that is weird becuase it represent ctrl+cmd+option+shift

and ideally it would be used at each layer to move tabs around the layer. (change tab 1 with tab 2 id - changes order)


