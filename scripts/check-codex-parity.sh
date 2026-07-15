#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

failures=0
fail() {
    echo "parity error: $*" >&2
    failures=$((failures + 1))
}

for role in architect auditor builder champion curator doctor driver guide hermit judge orchestrator; do
    [[ -f "defaults/.codex/agents/loom-${role}.toml" ]] \
        || fail "missing Codex agent for role: $role"
done

for skill in loom loom-sweep; do
    [[ -f "defaults/.agents/skills/${skill}/SKILL.md" ]] \
        || fail "missing Codex skill: $skill"
done

for role in auditor champion curator guide judge; do
    source_workflow=".github/workflows/loom-${role}.yml"
    installed_workflow="defaults/.github/workflows/loom-${role}.yml"
    [[ -f "$source_workflow" ]] || fail "missing source workflow: $source_workflow"
    [[ -f "$installed_workflow" ]] || fail "missing installed workflow: $installed_workflow"
    grep -Fq 'openai/codex-action@v1' "$source_workflow" \
        || fail "$source_workflow does not use the Codex Action"
    grep -Fq 'openai/codex-action@v1' "$installed_workflow" \
        || fail "$installed_workflow does not use the Codex Action"
done

if rg -n '@anthropic-ai/claude-code|ANTHROPIC_API_KEY|CLAUDE_API_KEY|claude -p' \
    .github/workflows/loom-*.yml defaults/.github/workflows/loom-*.yml >/dev/null; then
    fail "active support-role workflows contain Claude-only execution"
fi

[[ -f defaults/AGENTS.md ]] || fail "defaults/AGENTS.md is missing"
[[ -x defaults/scripts/spawn-codex.sh ]] || fail "spawn-codex.sh is not executable"

if (( failures > 0 )); then
    echo "Codex parity check failed with $failures error(s)." >&2
    exit 1
fi

echo "Codex parity check passed."
