# Folio — Claude Code Instructions

## Starting Work on an Issue

Before creating a feature branch or writing any code:

1. **Always sync `main` first**:
   ```
   git checkout main && git pull
   ```
2. Then create the feature branch from the updated `main`.

## Issue Workflow

After completing any GitHub issue:

1. **Never commit to `main`**. All work goes on a feature branch.
   - Branch naming: `feat/<issue-number>-<short-description>` (e.g. `feat/2-app-shell`)
   - Before any `git commit` or `git push`, run `git branch --show-current` and confirm you are NOT on `main`. If you are, stop and switch to a feature branch first.

2. **Update docs** before creating the PR:
   - `CLAUDE.md`: add any new patterns, conventions, or decisions introduced by this issue
   - `README.md`: reflect new features, changed behavior, or removed functionality

3. **Create a pull request** once the issue is done.
   - Use `gh pr create` targeting `main`.
   - Title: concise, ≤70 chars, follows Conventional Commits style.
   - Body must include:
     - **Summary**: what was built/changed (bullet points)
     - **Closes**: `Closes #<issue-number>`
     - **Test plan**: how to verify the changes work

4. **Do not merge the PR**. Leave it open for the user to review and merge.
