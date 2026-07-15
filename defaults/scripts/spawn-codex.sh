#!/usr/bin/env bash
# Codex-native non-interactive launcher for Loom sweeps.
set -euo pipefail

WORKSPACE="${LOOM_WORKSPACE:-$(git rev-parse --show-toplevel)}"
MODEL_ARGS=()
PROMPT=""
REQUESTED_MODEL="${LOOM_CODEX_MODEL:-}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--prompt) PROMPT="${2:?missing prompt}"; shift 2 ;;
        --model) REQUESTED_MODEL="${2:?missing model}"; shift 2 ;;
        --model=*) REQUESTED_MODEL="${1#--model=}"; shift ;;
        *) PROMPT="${PROMPT:+$PROMPT }$1"; shift ;;
    esac
done

command -v codex >/dev/null 2>&1 || { echo "error: 'codex' command not found" >&2; exit 127; }
[[ -n "$PROMPT" ]] || { echo "error: a Loom prompt is required (-p <prompt>)" >&2; exit 64; }

# Claude role defaults still appear in the provider-neutral workflow documents.
# They are capability hints, not valid Codex model IDs. Inherit Codex's current
# configured default for those values; pass through explicit Codex/GPT models.
case "$REQUESTED_MODEL" in
    ""|sonnet|opus|haiku|claude-*) ;;
    *) MODEL_ARGS+=(--model "$REQUESTED_MODEL") ;;
esac

# Each child directory under LOOM_CODEX_HOMES_DIR may hold an independently
# authenticated Codex home (use file credential storage). Select one
# deterministically from the terminal ID so concurrent sweeps distribute across
# accounts without sharing mutable auth state. LOOM_CODEX_HOME always wins.
if [[ -n "${LOOM_CODEX_HOME:-}" ]]; then
    export CODEX_HOME="$LOOM_CODEX_HOME"
elif [[ -n "${LOOM_CODEX_HOMES_DIR:-}" && -d "$LOOM_CODEX_HOMES_DIR" ]]; then
    HOMES=()
    while IFS= read -r home; do
        [[ -f "$home/auth.json" ]] && HOMES+=("$home")
    done < <(find "$LOOM_CODEX_HOMES_DIR" -mindepth 1 -maxdepth 1 -type d -print | sort)
    if (( ${#HOMES[@]} > 0 )); then
        selector="${LOOM_TERMINAL_ID:-$$}"
        checksum="$(printf '%s' "$selector" | cksum | awk '{print $1}')"
        export CODEX_HOME="${HOMES[$((checksum % ${#HOMES[@]}))]}"
        printf 'loom: selected Codex home %s\n' "$(basename "$CODEX_HOME")" >&2
    fi
fi

if [[ "$PROMPT" == /loom:sweep* ]]; then
    PROMPT="Use \$loom-sweep${PROMPT#/loom:sweep}"
fi

cd "$WORKSPACE"
if (( ${#MODEL_ARGS[@]} > 0 )); then
    exec codex exec --sandbox danger-full-access "${MODEL_ARGS[@]}" "$PROMPT"
fi
exec codex exec --sandbox danger-full-access "$PROMPT"
