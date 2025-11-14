# Cheatsheet for tmux

tmux allows managing multiple windows and panes of terminals in one terminal emulator and even more importantly you can detach
from them and reconnect later. Also you can easily group a preset set of terminal session and start 4-5 terminals that all belong
to one project, lets say you have a rails project, you can start, neovim, a console, lazygit, yazi, rails console and rails server all
at the same time, detach from the session go to a different project and switch back and all the services continue to run even while you are disconnected, e.g. rails server. Setting up sessions in an easy way is handled by tmuxinator.

## Examples

The leader in tmux is ctrl s with my config, that means every tmux command, by default must be prefixed by ctrl s, unless it specifies a different key, the default leader is ctrl b

### Misc

```sh 
# reload config, doesn't work for certain things, sometimes you have to kill all sessions and start a new session 
<leader> r

# start a project (collection of windows in tmux)
tmuxinator start PROJECT_NAME 
mux PROJECT_NAME               # alias works with auto complete

```

### Sessions

```sh 
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

# kill window 
<leader> &
```

### Panes

I'm not in love with panes, I mostly use windows(not the OS :D), so the shortcuts are mostly default and as a result quite awkward
```sh
# split pane, TODO: rebind to something more ergonomic
<leader> %

# zoom into pane, makes a pane temporarily fullscreen
<leader> z

# navigate panes, TODO: bind to vim motions if i ever use panes more, i actually did but it stopped working
<leader> arrow keys

# convert pane to window
<leader> !

# close pane TODO: requires confirmation, ugh
<leader> x
```
