# Loom orchestration

This repository uses Loom for label-driven development orchestration. Read `.loom/CLAUDE.md` as the canonical Loom workflow guide; despite its historical filename, its forge, label, worktree, testing, and safety rules apply to Codex too.

Use the repo skills under `.agents/skills/` for Loom workflows. Invoke `$loom-sweep` to move issues or PRs through their lifecycle. Delegate role work to the project agents in `.codex/agents/` when the selected skill asks for it.

Preserve Loom's role boundaries and label state machine. Never invent labels, bypass human approval of `loom:curated` issues, or merge unless the active workflow explicitly permits it.
