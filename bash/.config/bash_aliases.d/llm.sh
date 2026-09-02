# Local llama.cpp server helpers (llama-server on 127.0.0.1:8080)
# See ai-docs/llama-cpp-local-llm.md in the dotfiles repo

LLM_ENV_FILE="$HOME/.config/llama.cpp/env"
[ -f "$LLM_ENV_FILE" ] && source "$LLM_ENV_FILE"

LLM_BASE_URL="http://${LLAMA_HOST:-127.0.0.1}:${LLAMA_PORT:-8080}"
LLM_ALIAS="${LLAMA_MODEL_ALIAS:-gemma-4-26b}"

llm-up() {
  curl -fsS "$LLM_BASE_URL/health" >/dev/null 2>&1
}

llm() {
  if [ -z "$1" ]; then
    echo "usage: llm \"prompt\"" >&2
    return 1
  fi

  if ! llm-up; then
    echo "llama server down, starting (cold start takes ~30s)..." >&2
    systemctl --user start llama.service
    local i
    for i in $(seq 1 180); do
      llm-up && break
      sleep 1
    done
  fi

  if ! llm-up; then
    echo "llama server did not come up (check: llm-log)" >&2
    return 1
  fi

  local response
  response=$(curl -fsS "$LLM_BASE_URL/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg m "$LLM_ALIAS" --arg p "$*" \
      '{model: $m, messages: [{role: "user", content: $p}], max_tokens: 2048, reasoning_effort: "none"}')")

  printf '%s' "$response" | jq -r '.choices[0].message.content // empty'
  printf '%s' "$response" | jq -r 'if .choices[0].message.content == "" or .choices[0].message.content == null then .choices[0].message.reasoning_content // empty else empty end'
}

llm-start() {
  systemctl --user start llama.service
  echo "starting llama server (cold start takes ~30s), check: llm-status"
}

llm-stop() {
  systemctl --user stop llama.service
  echo "llama server stopped, VRAM/RAM freed"
}

llm-status() {
  systemctl --user status llama.service --no-pager
  if llm-up; then
    echo
    curl -fsS "$LLM_BASE_URL/health" | jq .
    echo
    nvidia-smi --query-gpu=memory.used,memory.total --format=csv
  fi
}

llm-log() {
  journalctl --user -u llama.service -f
}
