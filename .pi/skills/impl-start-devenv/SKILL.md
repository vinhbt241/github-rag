---
name: impl-start-devenv
description: Start a new git worktree development environment for implementing a GitHub issue. Creates an isolated worktree so multiple AI agents can work on the same project without conflicts, implements the issue based on docs/ plans, pushes to GitHub, and opens a PR.
---

# impl-start-devenv

## Purpose

Set up an isolated git worktree so multiple AI agents can work on the same project simultaneously without conflicting with each other. Then implement the issue, push, and create a PR.

## Input

The user provides one of the following:
- **Issue number** (e.g. `42`) → branch name: `feat/issue-42-<short-description>`
- **GitHub issue URL** (e.g. `https://github.com/owner/repo/issues/42`) → extract issue number, branch name: `feat/issue-42-<short-description>`
- **Custom branch name** (e.g. `feat/issue-42-add-search-endpoint`) → use as-is

## Process

### Phase 1: Set Up Worktree

1. **Parse the input** to determine the branch name:
   - If a URL is given, extract the issue number from the URL path (last segment).
   - If a plain number is given, use it as the issue number. Fetch the issue title from GitHub (via `gh issue view <number> --json title -q .title` or from the URL) to derive a short kebab-case description for the branch name: `feat/issue-<number>-<short-description>`.
   - If a string that looks like a branch name is given (contains `/` or `-`), use it directly.

2. **Fetch latest main**:
   ```bash
   git fetch origin main
   ```

3. **Create the branch and worktree**:
   ```bash
   git worktree add ../<project>-<branch-suffix> -b <branch-name> origin/main
   ```
   - The worktree path should be a sibling directory of the current project, named `<project-dir>-<branch-suffix>` where `<branch-suffix>` is the issue number or a short identifier from the branch name.
   - Example: if project is at `/home/vinh/projects/github-rag` and branch is `feat/issue-42-add-search`, worktree goes to `/home/vinh/projects/github-rag-issue-42`.

4. **Install dependencies** in the new worktree if applicable:
   - Check for `Gemfile`, `package.json`, `requirements.txt`, `go.mod`, etc. in the worktree root.
   - Run the appropriate install command (`bundle install`, `npm install`, `pip install -r requirements.txt`, etc.).
   - Skip this step if no dependency manifest is found.

5. **Announce the worktree**:
   ```
   Worktree created at: <worktree-path>
   Branch: <branch-name>
   ```

### Phase 2: Understand the Issue

6. **Read the implementation plan**:
   - Read all files under `docs/` in the **worktree** (architecture docs, product docs, README, etc.).
   - These documents contain the design decisions, data model, system overview, and requirements that guide implementation.

7. **Fetch issue details** (if an issue number or URL was provided):
   ```bash
   gh issue view <number> --json title,body,labels,comments
   ```
   - Understand what needs to be built, acceptance criteria, and any discussion.

8. **Plan the implementation**:
   - Based on the docs and issue details, identify:
     - Which files need to be created or modified
     - What models, controllers, services, migrations, tests, etc. are needed
     - The order of implementation
   - Present a brief implementation plan to the user before starting.

### Phase 3: Implement

9. **Implement the changes** inside the worktree directory:
   - Follow the architecture and design decisions from `docs/`.
   - Write clean, well-structured code.
   - Add/update tests for new functionality.
   - Follow the existing code style and conventions of the project.

10. **Run tests** to verify:
    - Run the project's test suite inside the worktree.
    - Fix any failures before proceeding.

11. **Commit changes**:
    ```bash
    cd <worktree-path>
    git add -A
    git commit -m "<type>: <description>

    Closes #<issue-number>

    <brief summary of changes>"
    ```
    - Use conventional commit style matching the project's conventions.
    - Reference the issue number in the commit message.

### Phase 4: Push and Create PR

12. **Push the branch**:
    ```bash
    git push origin <branch-name>
    ```

13. **Create the PR** using the project's PR template:
    - Read `.github/PULL_REQUEST_TEMPLATE.md` from the worktree.
    - Fill in each section of the template based on what was implemented:
      - **Linked Issue**: `Closes #<number>`
      - **Summary**: One-paragraph description of what was done and why.
      - **Approach**: Key decisions, trade-offs, design choices made during implementation.
      - **Blockers**: Any unresolved concerns, or `N/A`.
      - **Rollout Considerations**: Check applicable items (migrations, env vars, feature flags, backward compat) and provide details.
      - **Testing**: Check applicable items (unit tests, integration tests, manual testing).
      - **References**: Link to relevant docs, or `N/A`.
      - **Notes**: Anything reviewers should know.

    ```bash
    gh pr create \
      --base main \
      --head <branch-name> \
      --title "<type>/Issue-<issue_number> - <short description>" \
      --body-file /tmp/pr-body-<branch-name>.md
    ```
    - `<type>` is the change type (e.g. `feat`, `fix`, `refactor`, `chore`, `docs`).
    - `<issue_number>` is the GitHub issue number.
    - `<short description>` is a concise summary of the change.
    - Example: `feat/Issue-42 - Add hybrid search endpoint`
    - Write the filled PR template to a temp file and use `--body-file`.

14. **Report results**:
    ```
    ✅ Implementation complete!
    Branch: <branch-name>
    Worktree: <worktree-path>
    PR: <pr-url>
    ```

## Guidelines

- Always work inside the worktree directory, never in the main project directory.
- If the issue is ambiguous, ask the user for clarification before implementing.
- If tests fail and cannot be fixed easily, report to the user instead of pushing broken code.
- Keep commits atomic — one logical change per commit.
- If the implementation requires database migrations, run them and include them in the commit.
- If `gh` CLI is not available or not authenticated, instruct the user to set it up or provide the PR body for manual creation.
- After the PR is created, do NOT remove the worktree — the user may want to make review changes.

## Cleanup (Optional, User-Initiated)

If the user wants to clean up a worktree later:
```bash
cd <original-project-path>
git worktree remove <worktree-path>
git branch -d <branch-name>  # after PR is merged
```
