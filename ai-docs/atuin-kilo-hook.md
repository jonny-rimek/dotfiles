# Atuin ↔ Kilo agent hook

`kilo/.config/kilo/plugins/atuin.ts` (stowed to `~/.config/kilo/plugins/atuin.ts`)
records every command Kilo's `bash` tool runs into Atuin history, tagged as
agent-run. Kilo auto-loads plugins from `~/.config/kilo/plugins/*.{ts,js}`; no
`kilo.json` registration is needed.

The file is vendored from Atuin's opencode plugin
(`crates/atuin/contrib/opencode/atuin.ts`, tag v18.20.1) — Kilo is an opencode
fork, so the plugin API is the same. Upstream reference:
https://docs.atuin.sh/latest/guide/agent-hooks/

## Daily use

```bash
atuin search --author '$all-agent' -- ''   # agent-run commands (incl. Kilo's)
atuin search --author opencode -- ''       # only Kilo-run commands
atuin search --author '$all-user' -- ''    # only your own commands
```

Shell aliases (in `bash/.config/bash_aliases.d/atuin.sh`):

- `kh` — list Kilo-run commands (non-interactive)
- `khf` — fuzzy-pick a Kilo-run command via fzf; offers to run the selection

Note: the interactive atuin TUI (`ctrl-r` / `atuin search -i`) cannot show
agent commands — `--author` is silently dropped in interactive mode and the
TUI hardcodes `$all-user` (verified in v18.17.1 source; docs say this is not
configurable). That is why `khf` exists.

Interactive `atuin` search (Ctrl-R) hides agent commands by design. The bash
tool's `description` parameter is stored as the entry's intent. Commands denied
at Kilo's permission prompt and commands typed by the user (`!cmd` or terminal
panes) are not recorded, by design.

## How to tell it broke

It fails SILENTLY, on purpose: the plugin swallows every error so it can never
break Kilo. Check after running a command in Kilo:

```bash
atuin search --author opencode -- ''
```

No new entry → something below broke.

## Breakage modes and fixes

### 1. Atuin CLI drift (most likely)

Symptom: no entries after an atuin upgrade, or after the plugin is regenerated.
The vendored plugin shells out to `atuin history start --author opencode
[--intent X] -- CMD` and `atuin history end <id> --exit N`. If flags change,
each spawn fails and nothing is recorded.

Fix: test the CLI by hand:

```bash
id=$(atuin history start --author opencode -- true)
atuin history end "$id" --exit 0
atuin search --author opencode -- true
```

If a flag is missing/renamed, edit `startHistory` / `finish` in the vendored
plugin accordingly.

Known version gate at time of writing: atuin ≤ 18.19 has no `--author-kind`
flag and no `hook install opencode` (both landed in 18.20.0 — "Add agent hooks
for opencode", atuinsh/atuin#3844). That is why the vendored copy omits
`--author-kind agent`: entries still classify as agent-run by author NAME
(`opencode` is in atuin's recognized agent list), verified working on 18.17.1.

### 2. Kilo plugin API drift

Symptom: plugin loads but never records (hooks renamed/removed), or Kilo errors
on startup (export shape invalid). The plugin uses hooks
`tool.execute.before`, `shell.env`, `tool.execute.after` from
`@kilocode/plugin`.

Fix: check current signatures:

```bash
grep -n -A6 '"tool.execute.before"\|"shell.env"\|"tool.execute.after"' \
  ~/.config/kilo/node_modules/@kilocode/plugin/dist/index.d.ts
```

Adapt hook names/shapes in the vendored plugin. Keep exactly ONE export
(`AtuinPlugin`) — Kilo treats every export of the file as a plugin function and
fails to load the file otherwise.

### 3. Bash tool id renamed

The plugin filters on `input.tool === "bash"` (constant `BASH_TOOL` — Kilo
kept opencode's `bash` id for its shell tool). If a Kilo rename happens,
recording silently stops. Fix: update `BASH_TOOL`.

### 4. `@kilocode/plugin` missing

`~/.config/kilo/package.json` (not managed by this repo) depends on
`@kilocode/plugin`. The plugin's import is type-only, so a missing package
does not break runtime, but any typecheck of the plugin fails. Fix: restore
the dependency (`cd ~/.config/kilo && bun install` or equivalent).

### 5. Stow conflict

If `~/.config/kilo/plugins/` ever becomes a real directory (some tool wrote
into it), `stow --simulate` will fail. Fix: move the real files into
`kilo/.config/kilo/plugins/` in this repo, delete the real dir, re-stow.

### 6. Search-filter syntax drift

If `$all-agent` / `--author` stop working in `atuin search`, re-check
`atuin search --help` — filter values changed across atuin versions before.

## Regenerating from upstream

When atuin ≥ 18.20 is installed on this system:

```bash
atuin hook install opencode     # writes ~/.config/opencode/plugins/atuin.ts (safe to re-run)
diff ~/.config/opencode/plugins/atuin.ts kilo/.config/kilo/plugins/atuin.ts
rm -rf ~/.config/opencode       # opencode is not used on this machine
```

Then re-apply the local adaptations to the vendored copy (they are listed in
the file header):

1. `@opencode-ai/plugin` → `@kilocode/plugin`
2. header comment: install path + provenance + deviations
3. omit `--author-kind agent` while system atuin is ≤ 18.19 (drop this
   deviation once ≥ 18.20 is installed and the flag smoke-tests clean)

Finally re-stow: `stow --verbose --target=$HOME kilo` and restart Kilo.
