# Kilo TUI custom keybinds (tui.json)

Custom TUI keybinds live in `kilo/.config/kilo/tui.json` (stowed to
`~/.config/kilo/tui.json`). Format verified against the CLI 7.5.5 binary and
`packages/tui/src/config/keybind.ts` in Kilo-Org/kilocode (2026-08-28).

## Schema

```jsonc
{
  "$schema": "https://app.kilo.ai/tui.json",
  "keybinds": {
    "<definition_id>": "<key chord>", // string; or false / "none" to disable
    "theme_switch_mode": "<leader>d"
  }
}
```

- **Keys are the snake_case definition ids** from `TuiKeybind.Definitions`
  (`packages/tui/src/config/keybind.ts`): `theme_switch_mode`,
  `display_thinking`, `variant_cycle`, `messages_undo`, ...
  NOT the dotted command paths (`theme.switch_mode` is the internal command
  id and is REJECTED). Unknown keys make `parse()` throw
  `Unrecognized keybinds: ...` and ALL overrides are discarded — if one
  binding mysteriously "doesn't work but another does", suspect a typo'd id.
- **Chord syntax**: `<leader>x` (leader default `ctrl+x`), `ctrl+alt+k`,
  `shift+tab`, comma-separate alternatives: `"escape,q"`. Uppercase letters
  are distinct keys (`E` is used by defaults). Non-ASCII keys (`ü`) parse but
  never match — stick to ASCII.
- Overrides REPLACE the default binding entirely (binding `variant_cycle` to
  `<leader>k` unbinds its default `ctrl+t`).
- Precedence: project `.kilo/tui.json` > global `~/.config/kilo/tui.json`.
- Existing ids and their defaults: `/tui/keybinds` API on the TUI server, or
  grep the binary for `uE("<leader>` / `keybind("none"`.

## The mode-gating gotcha (why some binds can't work while typing)

Kilo's keymap is layered (opentui/keymap). Some command groups are registered
in layers with a `mode: "base"` condition (`require("opencode.mode", "base")`
against keymap data written by an internal "mode stack"):

- **Always-active layers** (no mode condition): app/theme/model/agent commands
  — `theme_switch_mode`, `variant_cycle`, `agent_list`, `model_list`, ...
  Leader chords for these work even while the prompt editor has focus.
- **Session view layers** (`mode: "base"`): ALL the display/session toggles —
  `display_thinking` (expand/collapse thinking), `messages_toggle_conceal`,
  `session_toggle_timestamps`, `session_undo`/`redo`, `session_compact`,
  `session_timeline`, `session_export`, ... Their leader chords are accepted
  as pending (shown in the hint bar below the input) but never dispatch while
  typing — the key silently falls through. Verified empirically: chord press
  does not flip the persisted `thinking_mode` in `~/.local/state/kilo/kv.json`.

Consequence: `display_thinking` (expand/collapse thinking) is NOT bindable to
a usable shortcut today — reach it via `/thinking` or `Ctrl+P` instead. If a
future kilo version initializes the keymap mode to `base` (the mode stack
default is `"base"` but the data key is never written until something pushes),
these bindings would start working with no config change.

## Current bindings (2026-08-29)

- None. `<leader>d` → `theme_switch_mode` was unbound on 2026-08-29
  (set to `"none"` in tui.json; the id has no default binding).

## Debugging checklist

1. Wrong id format (dotted instead of snake_case) → ALL overrides silently
   discarded. Test with a known-good id alongside.
2. Key conflicts: two ids on one chord — last/highest-priority layer wins.
3. Suspected mode gating: bind the same chord to `variant_cycle` as a control
   — if the control fires and the target doesn't, it's layer gating, not the
   chord.
4. Toggle-type commands persist state in `~/.local/state/kilo/kv.json`
   (`thinking_mode`, `theme_mode`, `timestamps`, ...) — diff it to verify a
   dispatch actually ran.
