-- Extra autostart processes

-- Fullscreen for specific applications across all workspaces
hl.window_rule({
    match      = { class = "^(firefox|Alacritty|obsidian|signal|Spotify)$" },
    fullscreen = true,
})

-- Pin apps to workspaces
hl.window_rule({
    match     = { class = "^(signal)$" },
    workspace = "8 silent",
})
hl.window_rule({
    match     = { class = "^(Spotify)$" },
    workspace = "9 silent",
})

-- Keep pinned workspaces alive before their apps launch
hl.workspace_rule({ workspace = "8", persistent = true })
hl.workspace_rule({ workspace = "9", persistent = true })

hl.on("hyprland.start", function()
    hl.exec_cmd("obsidian", { workspace = "7" })
    hl.exec_cmd("signal-desktop", { workspace = "8 silent" })
    hl.exec_cmd("spotify", { workspace = "9 silent" })
    hl.exec_cmd("firefox", { workspace = "1 silent" })
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/tmuxinator-startup.sh", { workspace = "2 silent" })
    hl.exec_cmd("sleep 3 && hyprctl dispatch workspace 7")
end)
