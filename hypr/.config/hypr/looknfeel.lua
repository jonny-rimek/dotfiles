-- Change the default Omarchy look'n'feel

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- No gaps between windows
    gaps_in = 0,
    gaps_out = 0,

    -- Use master layout instead of dwindle
    -- layout = "master",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners
    -- rounding = 8,

    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,

    blur = {
      enabled = false,
    },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

hl.window_rule({
    match   = { class = ".*" },
    opacity = "1.0 override 1.0 override",
})
