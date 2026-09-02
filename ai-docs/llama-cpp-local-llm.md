# Local LLM backup — llama.cpp + Gemma 4 26B-A4B

Operational notes for the local llama.cpp setup. Written by an AI agent, for AI agents
(and the human who owns this repo).

## What this is

- **Runtime**: `llama-cpp` (Arch extra) + `ggml-cuda` backend, RTX 4070 12 GB + 7800X3D
- **Model**: `unsloth/gemma-4-26B-A4B-it-qat-GGUF` → `gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf`
  (14.25 GB, MoE 26B total / 4B active) + `mmproj-F16.gguf` (vision encoder)
- **Serving**: `llama-server` as a systemd **user** unit (`~/.config/systemd/user/llama.service`,
  stowed from `llamacpp/`), on-demand only — **not** enabled at boot (frees ~10 GB VRAM /
  ~15 GB RAM when unused; this is a gaming machine)
- **Endpoint**: `http://127.0.0.1:8080` — web UI at `/`, OpenAI-compatible API at `/v1`
- **Kilo provider**: `llama-local` in `kilo/.config/kilo/kilo.json` (model id `gemma-4-26b`,
  matches `--alias` in the unit)

## Repo layout

| File | Purpose |
|---|---|
| `llamacpp/.config/llama.cpp/env` | Model dir/filenames, host/port, alias — sourced by bash helpers + download script |
| `llamacpp/.config/systemd/user/llama.service` | Server unit; flags (context, offload, threads) live here |
| `llamacpp/.local/bin/llm-model-download` | Idempotent HF downloader (size check; `--verify` adds sha256) |
| `omarchy-supplements/install-llama-cpp.sh` | pacman install of `llama-cpp` + `ggml-cuda` (root, idempotent) |
| `bash/.config/bash_aliases.d/llm.sh` | `llm`, `llm-start/stop/status/log` helpers |

NOTE: the systemd unit hardcodes its values (%h paths + flags) because EnvironmentFile
does not expand `$HOME`; the env file only drives the bash-side helpers. If you change
model/port/alias, update **both** the unit and the env file.

## Everyday use

```bash
llm "explain this error: ..."   # one-shot prompt; auto-starts server if down (~30s cold start)
llm-stop                        # free VRAM/RAM (before gaming)
llm-status                      # service + /health + VRAM usage
llm-log                         # follow server logs (shows t/s per request)
```

Web UI: http://127.0.0.1:8080 (chat, sampling settings, vision/image upload work).

OpenAI-compatible API:

```bash
curl -s http://127.0.0.1:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"gemma-4-26b","messages":[{"role":"user","content":"hi"}]}'
```

## Performance expectations & tuning

Measured on this rig (4070 12 GB + 7800X3D, DDR5 dual channel), gemma-4-26B-A4B QAT
(30 layers, 128 experts / 8 active, ~420 MiB of expert weights per layer):

| Config | Gen t/s | Prompt t/s | VRAM total (incl. desktop) |
|---|---|---|---|
| `--cpu-moe` (all experts CPU), 16k ctx | 42.6 | 80 | ~6.4 GB |
| `--n-cpu-moe 20`, 32k ctx, q8_0 KV (current unit) | 48.3–54.7 | 106+ | ~10.0 GB of 12.3 GB |

Context is 32768 because Kilo's system prompt + a working session runs ~20k tokens (16k
caused `request exceeds available context size` from Kilo); KV cache quantized to q8_0
to fit. Unit also uses `--parallel 1` (full ctx in one slot — Kilo sessions need depth)
and `--load-mode none` (server warns that CPU tensor overrides + mmap hurt performance;
costs ~14 GB RSS, fine with 64 GB RAM).

Tuning knobs if VRAM headroom changes:
- `--n-cpu-moe N`: lower N = more expert layers on GPU. Each layer ≈ 420 MiB. Keep
  ≥1.5 GB headroom for the desktop (watch `nvidia-smi`).
- Context: 32k fits at ~10.0 GB total; 64k would need KV headroom — either drop
  `--n-cpu-moe` to ~24 or accept tighter margin. `-ctk/-ctv q8_0` is already set.
- `-t 8` = physical cores; SMT threads usually hurt.

**systemd gotcha**: llama-server signals readiness via sd_notify, so systemd enforces a
start timeout (default 90s). Cold loads (cold page cache + CPU expert weight repack) can
exceed that and get killed mid-load — the unit sets `TimeoutStartSec=300`. If load times
grow, raise it further.

Kilo end-to-end verified via `kilo run -m llama-local/gemma-4-26b`: plain reply, bash
tool call (`hostname`), and read-tool file summary all work.

## Thinking model behavior

gemma-4-26B-A4B thinks by default: answers arrive in `message.reasoning_content` while
`message.content` stays empty until thinking finishes (often hundreds of tokens). Clients
that only read `content` (Kilo) show blank replies; the web UI renders the thinking
stream so it looks fine there.

The unit therefore runs with **`--reasoning off`** — thinking disabled server-wide. This
also overrides request-level `reasoning_effort`, so thinking cannot be re-enabled
per-request while the flag is set. To get thinking back: remove the flag from the unit,
restart, and use `"reasoning_effort": "none"` per-request when you don't want it (the
`llm` helper sends that automatically either way).

## Install / bootstrap (new machine)

1. `sudo ./install-omarchy-supplements.sh` (or just `sudo omarchy-supplements/install-llama-cpp.sh`)
2. `stow --verbose --target=$HOME llamacpp bash kilo` (simulate first!)
3. `llm-model-download` as your user (~15.5 GB, resumable)
4. `llm "hello"` — cold-starts the service and answers

## Breakage modes / fixes

| Symptom | Fix |
|---|---|
| `make_cpu_buft_list: no CPU backend found` crash loop | `ggml-cpu` package missing (it is NOT a hard dep of llama-cpp) → `sudo pacman -S ggml-cpu`; the install script includes it |
| `llm` says server did not come up | `llm-log`; usually model file missing → `llm-model-download` |
| OOM / CUDA error in journal after driver update | `ggml-cuda` may lag the nvidia driver; `pacman -Syu` both together |
| Unit won't start after flag edits | `llama-server --help` — flag names drift between releases (`--n-cpu-moe` vs `--override-tensor`) |
| Empty replies in API clients (Kilo) | thinking model: `content` empty while model thinks — unit now runs `--reasoning off`; see "Thinking model behavior" |
| Kilo can't reach provider | server down (`llm-status`); Kilo only sees it when the endpoint is healthy |
| Download keeps failing mid-way | curl `-C -` resume is built in; re-run `llm-model-download`; `--verify` for sha256 |

## Follow-ups (not yet done)

- llama-server warns the default port moves to :9931 in a future release — unit pins
  `--port 8080` explicitly, revisit if the flag disappears
- `gemma-4-12B-it-Q5_K_M.gguf` (8.4 GB, fits fully in VRAM) as a "fast mode" second
  model — download script is parameterized, unit would need a second instance/template
- MTP speculative decoding (`mtp-gemma-4-26B-A4B-it.gguf` draft file in the same HF repo,
  this build supports `--spec-type draft-mtp`) for a potential t/s boost
- Point Kilo `small_model` at the local provider to save cloud tokens on titles/summaries
