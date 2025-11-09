#!/usr/bin/env bash
# Detect OS theme and set tmux-dotbar colors accordingly

detect_theme() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if defaults read -g AppleInterfaceStyle &>/dev/null; then
      echo "dark"
    else
      echo "light"
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v gsettings &>/dev/null; then
      theme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
      if [[ "$theme" == *"dark"* ]]; then
        echo "dark"
        return
      elif [[ "$theme" == *"light"* ]]; then
        echo "light"
        return
      fi
    fi

    if command -v kreadconfig5 &>/dev/null; then
      theme=$(kreadconfig5 --group General --key ColorScheme 2>/dev/null)
      if [[ "$theme" == *"Dark"* ]] || [[ "$theme" == *"dark"* ]]; then
        echo "dark"
        return
      fi
    fi

    if [[ -f ~/.config/gtk-3.0/settings.ini ]]; then
      theme=$(grep "gtk-theme-name" ~/.config/gtk-3.0/settings.ini | cut -d= -f2)
      if [[ "$theme" == *"dark"* ]] || [[ "$theme" == *"Dark"* ]]; then
        echo "dark"
        return
      fi
    fi

    echo "light"
  else
    echo "light"
  fi
}

apply_theme() {
  local theme=$1

  if [[ "$theme" == "dark" ]]; then
    tmux set-option -g @tmux-dotbar-bg "#002b36"
    tmux set-option -g @tmux-dotbar-fg "#586e75"
    tmux set-option -g @tmux-dotbar-fg-current "#93a1a1"
    tmux set-option -g @tmux-dotbar-fg-session "#839496"
    tmux set-option -g @tmux-dotbar-fg-prefix "#268bd2"
  else
    tmux set-option -g @tmux-dotbar-bg "#fdf6e3"
    tmux set-option -g @tmux-dotbar-fg "#93a1a1"
    tmux set-option -g @tmux-dotbar-fg-current "#586e75"
    tmux set-option -g @tmux-dotbar-fg-session "#839496"
    tmux set-option -g @tmux-dotbar-fg-prefix "#268bd2"
  fi
}

THEME=$(detect_theme)
apply_theme "$THEME"
