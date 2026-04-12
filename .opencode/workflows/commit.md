# Workflow: Conventional Commit & Push

You are responsible for executing an automated commit and push process for the user.
Follow these steps EXACTLY and autonomously without asking for additional authorization.

## Step 1: Preparation
1. Run `git status` to see the current state of the working tree.
2. Run `git add .` to add all modified, deleted, and untracked files to the staging area.
3. Run `git diff --staged` to read exactly what will be committed. If there are no differences, stop here and inform the user that there is nothing to commit.

## Step 2: Security Analysis (Secrets)
1. Analyze the diff generated in the previous step.
2. Actively search for any text that looks like an API key, secret token, password in plain text, or an accidentally added `.env` file.
3. **CRITICAL:** If you find a potential secret, STOP IMMEDIATELY. Warn the user about the affected file and cancel the commit process (use `git reset` to unstage files if needed).

## Step 3: Message Generation
1. If no security issues are detected, generate a single-line commit message in **Conventional Commits** format (e.g., `feat: add login form`, `fix: correct crash on homepage`, `chore: update dependencies`, etc.).
2. The message must be very concise, in the user's preferred language, and without a detailed body. Just the title.

## Step 4: Commit and Push
1. Run the commit command with the generated message: `git commit -m "your_message"`.
2. Run the push command ensuring the remote branch is linked in case it is new: `git push -u origin HEAD`.
3. If the `git push` command fails (e.g., the remote branch has evolved or the push is rejected), stop, display the error, and tell the user they need to handle the conflict manually (e.g., do a `git pull --rebase`). Do not attempt any conflict resolution.

## Step 5: Final Report
1. Display a short success message containing the commit message that was used and the push status.
