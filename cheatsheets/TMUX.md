# Cheatsheet for tmux

tmux allows managing multiple windows and panes of terminals in one terminal emulator and even more importantly you can detach
from them and reconnect later. Also you can easily group a preset set of terminal session and start 4-5 terminals that all belong
to one project, lets say you have a rails project, you can start, neovim, a console, lazygit, yazi, rails console and rails server all
at the same time, detach from the session go to a different project and switch back and all the services continue to run even while you are disconnected, e.g. rails server. Setting up sessions in an easy way is handled by tmuxinator.

## Examples

The leader in tmux is ctrl s with my config, that means every tmux command, by default must be prefixed by ctrl s, unless it specifies a different key, the default leader is ctrl b

### Misc

```sh 
# zenmode (hide status bar)
<leader> Z

# shows all shortcuts
<leader> ?

# opens popup to open tmuxinator sessions
<leader> m

# reload config, doesn't work for certain things, sometimes you have to kill all sessions and start a new session 
<leader> r

# start a project (collection of windows in tmux)
mux PROJECT_NAME               # alias works with auto complete

# start a tmuxinator session from an fzf popup (same as mux, from inside tmux)
<leader> m                     # switches to the session if it is already running

<leader> ESC # enter copy mode, it's the same as vim normal mode

Navigation:      j/k (down/up), h/l (left/right), Ctrl-u/d (page up/down)
Search:          / (forward), ? (backward), n/N (next/prev match)
Selection:       Space or v (start selection), y (yank)
Exit:            q, Enter, or Escape
```

### Sessions

```sh 
# new session
<leader> :new # new session with default name, some number that is incremented
<leader> :new-session -s NAME # specify a  name 
tmux # must not be in a tmux session, from the cli simply typing tmux will start a new session with a number 
tmux new-session -s NAME # same as from within a tmux session

# detach from session
<leader> d 

# kill session, custom keybind
<leader> + 

# switch bewtween active session
<leader> s  # from inside tmux 

# view all active session
tmux ls     # from cli 

```

### Windows

```sh
# new window
<leader> c

# next window 
alt k

# previous window 
alt j 

# window directly
alt NUMBER

# kill window capital X
<leader> X
```

### Panes

I'm not in love with panes, I mostly use windows(not the OS :D), so the shortcuts are mostly default and as a result quite awkward
```sh
# split pane vertically
<leader> v

# split horizontally
<leader> h

# zoom into pane, makes a pane temporarily fullscreen
<leader> z

# navigate to right pane
ctrl k
<leader> k 


# navigate to left pane
ctrl j
<leader> j

# convert pane to window
<leader> !

# close pane
<leader> x
```

### Resizing Panes

ctrl + alt + shift + arrowkeys
