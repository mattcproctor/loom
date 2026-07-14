---
name: loom
description: Operate Loom's label-driven forge workflow with Codex. Use for issue curation, implementation, PR review, repair, prioritization, auditing, and orchestration.
---

# Loom for Codex

Read `.loom/CLAUDE.md` for the shared workflow and label rules. Select the matching role instructions from `.claude/commands/loom/<role>.md`; those files are the canonical provider-neutral workflows despite their legacy location and slash-command wording.

Interpret `$ARGUMENTS` as arguments in the current request. Interpret Claude `Task` calls as Codex subagent delegation. Use the matching custom agent in `.codex/agents/` when available, otherwise delegate to a `worker` with the role document included in its task.

Keep Loom's forge operations, confirmation gates, label ownership, worktree isolation, tests, checkpoints, and merge restrictions unchanged.
