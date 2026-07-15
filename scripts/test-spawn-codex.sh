#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin" "$TMP/work" "$TMP/homes/account-a" "$TMP/homes/account-b"
touch "$TMP/homes/account-a/auth.json" "$TMP/homes/account-b/auth.json"
git -C "$TMP/work" init -q

FAKE_LOG="$TMP/codex.log"
export FAKE_LOG
printf '%s\n' '#!/usr/bin/env bash' 'printf "CODEX_HOME=%s\nargv=%s\n" "${CODEX_HOME:-unset}" "$*" >> "$FAKE_LOG"' > "$TMP/bin/codex"
chmod +x "$TMP/bin/codex"
export PATH="$TMP/bin:$PATH"

LOOM_WORKSPACE="$TMP/work" "$ROOT/defaults/scripts/spawn-codex.sh" -p '/loom:sweep 42' --model opus
grep -Fq 'argv=exec --sandbox danger-full-access Use $loom-sweep 42' "$FAKE_LOG"
if grep -Fq -- '--model opus' "$FAKE_LOG"; then
    echo "legacy Claude model alias leaked to Codex" >&2
    exit 1
fi

: > "$FAKE_LOG"
LOOM_WORKSPACE="$TMP/work" LOOM_CODEX_MODEL="gpt-test-model" \
    "$ROOT/defaults/scripts/spawn-codex.sh" -p '/loom:sweep 43'
grep -Fq -- '--model gpt-test-model' "$FAKE_LOG"

: > "$FAKE_LOG"
LOOM_WORKSPACE="$TMP/work" LOOM_CODEX_HOMES_DIR="$TMP/homes" LOOM_TERMINAL_ID="stable-id" \
    "$ROOT/defaults/scripts/spawn-codex.sh" -p '/loom:sweep 44'
grep -Eq "CODEX_HOME=$TMP/homes/account-(a|b)" "$FAKE_LOG"

echo "spawn-codex tests passed"
