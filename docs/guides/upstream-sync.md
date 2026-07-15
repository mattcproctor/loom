# Keeping Loomdex Current

Loomdex is a long-lived Codex distribution of Loom. Keep the orchestration protocol close to `rjwalters/loom` and isolate Codex-specific behavior in `.agents/`, `.codex/`, `spawn-codex.sh`, and the small daemon/installer adapter surface.

## Remote setup

The expected remotes are:

```text
origin    https://github.com/mattcproctor/loom.git
upstream  https://github.com/rjwalters/loom.git
```

Add or repair the upstream remote with:

```bash
git remote add upstream https://github.com/rjwalters/loom.git
# If it already exists:
git remote set-url upstream https://github.com/rjwalters/loom.git
```

## Merge an upstream release

Use a merge commit for this long-lived fork. Do not rebase published Loomdex history or force-push `main`.

```bash
git status --short
git fetch upstream
git switch main
git merge --no-ff upstream/main
```

Resolve conflicts without dropping either upstream behavior or the Codex adapter. The most likely conflict hotspots are:

- `README.md` and installer completion messages
- `defaults/.claude/commands/loom/sweep.md`
- `defaults/scripts/spawn-loop.sh` and `spawn-codex.sh`
- `loom-daemon/src/sweep_registry.rs`
- scaffolding and installation-manifest code
- `.github/workflows/loom-*.yml`

When upstream adds a role, add a matching `defaults/.codex/agents/loom-<role>.toml`. When it changes model-selection or token behavior, preserve the workflow intent but translate it to Codex models, reasoning effort, `CODEX_HOME`, or `CODEX_API_KEY` semantics.

## Required verification

```bash
./scripts/check-codex-parity.sh
./scripts/test-spawn-codex.sh
./scripts/test-installer.sh
cargo fmt --all -- --check
cargo test --workspace --locked --all-features --no-fail-fast
```

Run strict Clippy as well, while distinguishing new adapter warnings from any pre-existing upstream lint debt:

```bash
cargo clippy --workspace --all-targets --all-features --locked -- -D warnings
```

Review the merged diff, commit conflict resolutions if the merge did not already create a commit, and push normally:

```bash
git push origin main
```

## Automation policy

`.github/workflows/upstream-drift.yml` checks daily for new upstream commits, runs the lightweight Codex parity guard, and opens one operator issue when synchronization is needed. It deliberately does not merge upstream automatically: changes to canonical role workflows, labels, installation ownership, or daemon dispatch require review.
