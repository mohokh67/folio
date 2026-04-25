# Folio — Claude Code Instructions

## Issue Workflow

After completing any GitHub issue:

1. **Never commit to `main`**. All work goes on a feature branch.
   - Branch naming: `feat/<issue-number>-<short-description>` (e.g. `feat/2-app-shell`)
   - Before any `git commit` or `git push`, run `git branch --show-current` and confirm you are NOT on `main`. If you are, stop and switch to a feature branch first.

2. **Create a pull request** once the issue is done.
   - Use `gh pr create` targeting `main`.
   - Title: concise, ≤70 chars, follows Conventional Commits style.
   - Body must include:
     - **Summary**: what was built/changed (bullet points)
     - **Closes**: `Closes #<issue-number>`
     - **Test plan**: how to verify the changes work

3. **Do not merge the PR**. Leave it open for the user to review and merge.
