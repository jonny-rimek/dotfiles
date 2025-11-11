# Cheatsheet for tmux

tmux allows managing multiple windows and panes of terminals in one terminal emulator and even more importantly you can detach
from them and reconnect later. Also you can easily group a preset set of terminal session and start 4-5 terminals that all belong
to one project, lets say you have a rails project, you can start, neovim, a console, lazygit, yazi, rails console and rails server all
at the same time, detach from the session go to a different project and switch back and all the services continue to run even while you are disconnected, e.g. rails server. Setting up sessions in an easy way is handled by tmuxinator.

## Examples

```sh 
# leader in tmux
# ctrl s, that means every tmux, by default must be prefixed by ctrl s, the default leader is ctrl b

# detach from session 
<leader> d 

# reload config, doesn't work for certain things, sometimes you have to kill all sessions and start a new session 
<leader> r

# kill session, custom keybind
<leader> + 

# view all active session
<leader> s  # from inside tmux 
tmux ls     # from cli 

# split pane, TODO: rebind to something more ergonomic
<leader> %

# close pane
# TODO: 

# start a project (collection of windows in tmux)
tmuxinator start PROJECT_NAME 
mux PROJECT_NAME               # alias works with auto complete
```
