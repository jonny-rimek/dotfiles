-- Application bindings
-- See current bindings with: omarchy menu keybindings --print

local terminal = "uwsm-app -- xdg-terminal-exec"
local browser = "omarchy-launch-browser"

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal .. ' --dir="$(omarchy-cmd-terminal-cwd)"'), { description = "Terminal" })
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window"), { description = "File manager" })
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd(browser), { description = "Browser" })
hl.bind("SUPER + SHIFT + ALT + B", hl.dsp.exec_cmd(browser .. " --private"), { description = "Browser (private)" })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("omarchy-launch-or-focus spotify"), { description = "Music" })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("omarchy-launch-editor"), { description = "Editor" })
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("omarchy-launch-tui btop"), { description = "Activity" })
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("omarchy-launch-tui lazydocker"), { description = "Docker" })
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd('omarchy-launch-or-focus signal "uwsm-app -- signal-desktop"'), { description = "Signal" })
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd('omarchy-launch-or-focus "^obsidian$" "uwsm-app -- obsidian -disable-gpu --enable-wayland-ime"'), { description = "Obsidian" })
hl.bind("SUPER + SHIFT + Y", hl.dsp.exec_cmd("omarchy-launch-tui yazi"), { description = "Yazi" })

-- If your web app url contains #, type it as ## to prevent a lua comment
-- hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd('omarchy-launch-webapp "https://chatgpt.com"'), { description = "ChatGPT" })
-- hl.bind("SUPER + SHIFT + ALT + A", hl.dsp.exec_cmd('omarchy-launch-webapp "https://grok.com"'), { description = "Grok" })
-- hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd('omarchy-launch-webapp "https://app.hey.com/calendar/weeks/"'), { description = "Calendar" })
-- hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd('omarchy-launch-webapp "https://app.hey.com"'), { description = "Email" })
-- hl.bind("SUPER + SHIFT + ALT + G", hl.dsp.exec_cmd('omarchy-launch-or-focus-webapp "WhatsApp" "https://web.whatsapp.com/"'), { description = "WhatsApp" })
-- hl.bind("SUPER + SHIFT + CTRL + G", hl.dsp.exec_cmd('omarchy-launch-or-focus-webapp "Google Messages" "https://messages.google.com/web/conversations"'), { description = "Google Messages" })
-- hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd('omarchy-launch-webapp "https://photos.google.com/"'), { description = "Google Photos" })
-- hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd('omarchy-launch-webapp "https://x.com/"'), { description = "X" })
-- hl.bind("SUPER + SHIFT + ALT + X", hl.dsp.exec_cmd('omarchy-launch-webapp "https://x.com/compose/post"'), { description = "X Post" })

-- Unbind Omarchy defaults for the keys rebound below (case-sensitive)
hl.unbind("SUPER + J") -- togglesplit
hl.unbind("SUPER + K") -- togglesplit / keybindings menu
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
hl.unbind("SUPER + TAB")
hl.unbind("ALT + TAB")

-- Vim-like window focus
hl.bind("SUPER + J", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + H", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "d" }))

-- Workspace switching
hl.bind("SUPER + SHIFT + J", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "previous" }), { description = "Previous workspace" })

-- Power
hl.bind("SUPER + SHIFT + Z", hl.dsp.exec_cmd("systemctl suspend"), { description = "Suspend" })
hl.bind("SUPER + SHIFT + CTRL + Z", hl.dsp.exec_cmd("systemctl poweroff"), { description = "Poweroff" })
