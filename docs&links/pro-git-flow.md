# Git Workflow: Private Configs with Worktrees

This workflow separates your personal configuration (Nix, direnv, etc.) from your code contributions using **Git Worktrees** and a **Rebase Strategy**.

**The Golden Rule:** You work on a "dirty" branch (with personal files) locally, but you clean it using rebase before pushing to your fork to create the Pull Request.

## 1. Initial Setup (The "Bare" Repo)
Use a bare clone to manage multiple worktrees easily without a cluttered root directory.

```bash
# 1. Create a directory for the project
mkdir my-project && cd my-project

# 2. Clone as a bare repository
git clone --bare <your-fork-url> .git

# 3. Configure remotes inside the bare repo
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git remote add upstream <original-repo-url>
git fetch --all

# 4. Create your "personal" worktree (your private base)
git worktree add personal upstream/main
cd personal
touch .envrc flake.nix # Add your private files here
git add .
git commit -m "CONFIG: Add personal dev environment"
git branch personal
git switch personal
git push -u origin personal

gh repo edit bro-adm/kserve --default-branch personal
# delete the copied master/main /wahtever branch from origin
git push origin --delete master
```

## 2. Daily Workflow
Create new worktrees from `personal`

```bash
# From the root 'my-project' folder:

# 1. Create a new folder 'feat-login' based on 'personal'
git worktree add -b <branch> feat-login personal

# 2. Move into that folder to work
cd feat-login

# 3. Work and commit as normal (LOCAL ONLY)
git add src/code.js
git commit -m "feat: implement login"

# STOP: Do NOT push yet. Your history currently includes your private files.
```

## 3. Pre PR Cleanup (Rebase onto)
When finished, we want the branch on the fork to be clean commit wise of the personal files (commits) we built it from.

```bash
# Inside the 'feat-login' folder:

# 1. Graft feature commits onto clean upstream
# Logic: "Take my new commits, but place them on top of upstream/main, ignoring the personal config commits."
git rebase --onto upstream/main personal HEAD

# 2. Push the NOW CLEAN branch to your fork
git push -u origin feat-login

# 3. Open Pull Request from 'origin/feat-login' to 'upstream/main' on GitHub/GitLab
```

## 4. Updating Personal
Keeping uptodate on the upstream

```bash
# Go to your permanent personal folder
cd ../personal

# Pull latest upstream and replay your personal config on top
git fetch upstream
git rebase upstream/main

# Force push to origin/personal (This is your private backup)
git push --force-with-lease origin personal
```

## Visual Summary
**Before Cleanup (Local state):**
`[Upstream]` -> `[Personal Config]` -> `[Feature Commits]`

**After Cleanup (Ready for PR):**
`[Upstream]` -> `[Feature Commits]`
