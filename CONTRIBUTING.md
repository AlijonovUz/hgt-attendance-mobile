# Contributing

This repository follows the standard GitHub flow built around three long-lived
branches. Read this before opening a pull request.

## Branch model

| Branch | Purpose                                                        | Receives merges from |
| ------ | -------------------------------------------------------------- | -------------------- |
| `dev`  | **Default branch.** Active development integration line.       | `feature/*`, `bugfix/*` |
| `main` | Stable, release-ready integration of validated `dev` work.     | `dev`                |
| `prod` | Production. What is currently deployed to end users.           | `main`               |

All day-to-day work targets `dev`. Promotion flows one way:
`feature/*` → `dev` → `main` → `prod`.

## The workflow (Issue → Branch → PR → Merge)

This is the official GitHub flow. Every change follows it:

1. **Open an Issue** describing the bug or feature. The issue is the unit of
   work and the place discussion happens.
2. **Create a branch from `dev`**, linked to that issue. From the issue page use
   *"Create a branch"* (under Development), or branch manually:

   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/123-short-description   # or bugfix/123-...
   ```

   Branch naming: `feature/<issue#>-<slug>` or `bugfix/<issue#>-<slug>`.
3. **Develop.** Commit in small, focused steps with clear messages.
4. **Open a Pull Request into `dev`.** In the PR description, link the issue with
   a closing keyword so it closes automatically on merge:

   ```
   Closes #123
   ```

   Accepted keywords: `Closes`, `Fixes`, `Resolves` (+ `#issue`).
5. **Review, then merge into `dev`.** On merge:
   - the linked issue closes automatically (closing keywords act on merges into
     the **default branch**, which is `dev`);
   - the merged head branch is deleted automatically.

> Direct pushes to `dev` are not part of this flow. Changes reach `dev` only
> through a pull request.

## Releasing

- Promote `dev` → `main` via a PR once a set of changes is validated.
- Promote `main` → `prod` via a PR to ship to production.

## References

- GitHub flow: https://docs.github.com/en/get-started/using-github/github-flow
- Linking a PR to an issue: https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue
- About protected branches: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches
