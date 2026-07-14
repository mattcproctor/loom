#!/usr/bin/env bash
# Codex-native non-interactive launcher for Loom sweeps.
set -euo pipefail

WORKSPACE="${LOOM_WORKSPACE:-$(git rev-parse --show-toplevel)}"
MODEL_ARGS=()
PROMPT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--prompt) PROMPT="${2:?missing prompt}"; shift 2 ;;
        --model) MODEL_ARGS+=(--model "${2:?missing model}"); shift 2 ;;
        --model=*) MODEL_ARGS+=("$1"); shift ;;
        *) PROMPT="${PROMPT:+$PROMPT }$1"; shift ;;
    esac
done

command -v codex >/dev/null 2>&1 || { echo "error: 'codex' command not found" >&2; exit 127; }
[[ -n "$PROMPT" ]] || { echo "error: a Loom prompt is required (-p <prompt>)" >&2; exit 64; }

if [[ "$PROMPT" == /loom:sweep* ]]; then
    PROMPT="Use \$loom-sweep ${PROMPT#/loom:sweep}"
fi

cd "$WORKSPACE"
exec codex exec --sandbox danger-full-access "${MODEL_ARGS[@]}" "$PROMPT"
