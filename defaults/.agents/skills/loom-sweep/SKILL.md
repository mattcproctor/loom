---
name: loom-sweep
description: Run Loom issues or PRs end-to-end with Codex, including Builder, Judge, Doctor, and merge-ready transitions. Use when asked to sweep issue or PR numbers.
---

# Loom sweep for Codex

Read `.claude/commands/loom/sweep.md` completely and execute its lifecycle. It is the canonical sweep specification.

Apply these mappings:

- Treat text following `$loom-sweep` as `$ARGUMENTS`.
- Replace Claude `Task` calls with Codex delegation to the corresponding `.codex/agents/` agent.
- For parallel waves, explicitly spawn the requested independent Codex subagents, wait for them, and reconcile results.
- If delegation is unavailable, run roles sequentially using `.claude/commands/loom/<role>.md`.
- Treat Claude model aliases and IDs in the canonical document as capability hints. Do not pass them to Codex. Let each custom agent inherit the current Codex model and use its configured reasoning effort unless the operator explicitly supplied a Codex model ID.
- For Stage -1 pool detection, a Codex multi-account pool means at least two child directories containing `auth.json` under `LOOM_CODEX_HOMES_DIR`. Claude `.loom/tokens` and `ACCOUNT_KEY_*` values do not constitute a Codex pool.
- Keep daemon MCP dispatch, checkpointing, label validation, confirmation, and dry-run behavior unchanged.

Continue until every item is merged, merge-ready, blocked according to the workflow, or the dry run is complete.
