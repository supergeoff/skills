---
name: skill-install
description: Install or update agent skills from Git repositories into the local ~/skills directory, organized by maintainer. Use when the user wants to install, download, or fetch skills from GitHub or any Git repository, or when a skill is referenced but not yet available locally. Automatically clones repos and organizes skills in the ~/skills/<maintainer>/ folder structure. If a skill is already installed, checks the remote for newer commits and updates automatically. Works with a specific repo URL or defaults to the official Anthropic skills repository (https://github.com/anthropics/skills.git). Trigger this skill whenever the user mentions installing skills, downloading skills, cloning skill repos, setting up skills, bootstrapping a skills environment, or updating skills, even if they don't explicitly say "install skills".
---

# Skill Install

Install or update agent skills from Git repositories into a structured `~/skills/<maintainer>/<repo-name>` directory. This skill enables bootstrapping a complete skills environment on a fresh machine with only `git`, `python3`, `nodejs`, and `curl` available.

## Helper Functions

```bash
is_remote_newer() {
  local repo_dir="$1"
  local branch="${2:-main}"
  
  cd "$repo_dir" 2>/dev/null || return 1
  
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
  
  git fetch origin "$branch" 2>/dev/null || return 1
  
  local_local=$(git log -1 --format=%ct HEAD 2>/dev/null)
  local_remote=$(git log -1 --format=%ct "origin/$branch" 2>/dev/null)
  
  [ -n "$local_local" ] && [ -n "$local_remote" ] && [ "$local_remote" -gt "$local_local" ]
}

force_update_repo() {
  local repo_dir="$1"
  
  cd "$repo_dir" 2>/dev/null || return 1
  
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
  
  git fetch origin "$branch" 2>/dev/null || return 1
  git reset --hard "origin/$branch" 2>/dev/null
}
```

## How It Works

When invoked, this skill:

1. **Parses the repository URL** to extract the maintainer (owner) and repo name
2. **Ensures the `~/skills/<maintainer>` directory exists** — creates it if missing
3. **Clones the target repository** into `~/skills/<maintainer>/<repo-name>/` (or updates it if already present)
4. **Discovers and validates skills** — scans the cloned repo for valid skill folders (containing `SKILL.md` or `README.md` with frontmatter)
5. **Reports what was installed** — lists all available skills with their names and descriptions

## Maintainer-Based Organization

Skills are organized by their GitHub owner (maintainer) to keep things clean and avoid conflicts:

- The **maintainer slug** is the GitHub username/organization from the URL, lowercased
- Each maintainer gets their own subdirectory under `~/skills/`
- Each repo is cloned inside its maintainer's directory

Examples:
- `https://github.com/anthropics/skills.git` → `~/skills/anthropics/skills/`
- `https://github.com/myorg/cool-skills.git` → `~/skills/myorg/cool-skills/`
- `https://github.com/My-Repo-Owner/ai-tools.git` → `~/skills/my-repo-owner/ai-tools/`

The maintainer slug is obtained by lowercasing the GitHub owner from the URL. Since GitHub usernames are already URL-safe (lowercase, hyphens instead of spaces), the slug is simply the owner portion of the URL converted to lowercase.

## Installation Modes

### Mode 1: Install from a Specific Repository URL

Provide a full GitHub (or any Git) repository URL:

> "Install skills from https://github.com/anthropics/skills.git"
> "Clone the skill repo https://github.com/myorg/my-skills"

The skill will clone that specific repo into `~/skills/<maintainer>/<repo-name>/`.

### Mode 2: Install Default Skills (Anthropic)

If no repository URL is provided, the skill defaults to installing Anthropic's official skills and then checks all installed repos for updates:

> "Install the default skills"
> "Set up my skills environment"
> "Bootstrap skills"

This:
1. Installs or updates `https://github.com/anthropics/skills.git` into `~/skills/anthropics/skills/`
2. Checks ALL repositories in `~/skills/` for newer remote commits
3. Updates any repos where the remote HEAD is newer than local HEAD

The default behavior ensures the user's skills environment is always up to date without requiring explicit update commands.

## Step-by-Step Instructions

Follow these steps in order when the user asks to install skills:

### Step 1: Determine the Repository

- If the user provides a URL (e.g., `https://github.com/org/repo.git`), use that URL
- If no URL is provided, use the default: `https://github.com/anthropics/skills.git`

### Step 2: Extract Maintainer and Repo Name

Parse the URL to extract the maintainer slug and repo name:

```bash
# Parse the repo URL to extract maintainer and repo name
# Supports: https://github.com/OWNER/REPO.git, git@github.com:OWNER/REPO.git, etc.

REPO_URL="<repo-url>"

# Extract the path portion and parse owner/repo
# For https://github.com/anthropics/skills.git → maintainer=anthropics, repo=skills
# For git@github.com:myorg/cool-skills.git → maintainer=myorg, repo=cool-skills

# Handle SSH format: git@github.com:owner/repo.git
if [[ "$REPO_URL" == *@* ]]; then
  PATH_PART=$(echo "$REPO_URL" | sed 's|.*:||' | sed 's|\.git$||')
else
  PATH_PART=$(echo "$REPO_URL" | sed 's|.*github.com/||' | sed 's|\.git$||')
fi

MAINTAINER=$(echo "$PATH_PART" | cut -d'/' -f1 | tr '[:upper:]' '[:lower:]')
REPO_NAME=$(echo "$PATH_PART" | cut -d'/' -f2)
```

Examples:
- `https://github.com/anthropics/skills.git` → maintainer: `anthropics`, repo: `skills`
- `https://github.com/myorg/cool-skills.git` → maintainer: `myorg`, repo: `cool-skills`
- `git@github.com:My-Repo-Owner/ai-tools.git` → maintainer: `my-repo-owner`, repo: `ai-tools`

### Step 3: Create the Skills Directory

```bash
mkdir -p "$HOME/skills/$MAINTAINER"
```

### Step 4: Clone or Update the Repository

Check if the target directory already exists and if the remote has newer commits:

```bash
TARGET_DIR="$HOME/skills/$MAINTAINER/$REPO_NAME"

if [ -d "$TARGET_DIR/.git" ]; then
  if is_remote_newer "$TARGET_DIR"; then
    echo "📦 Update available for $MAINTAINER/$REPO_NAME — updating..."
    force_update_repo "$TARGET_DIR"
  else
    echo "✓ $MAINTAINER/$REPO_NAME is already up to date"
  fi
else
  git clone "$REPO_URL" "$TARGET_DIR"
fi
```

**Note**: Updates are automatic and use `git reset --hard` to ensure the local state matches the remote, discarding any local changes.

### Step 5: Discover Installed Skills

Scan the cloned repository for skill folders. A valid skill folder contains either:
- A `SKILL.md` file (Anthropic skills standard)
- A `README.md` file with YAML frontmatter (OpenWebUI import format)

Run this discovery scan:

```bash
bash -c '
echo "=== Installed Skills in ~/skills/$MAINTAINER/$REPO_NAME ==="
find "$HOME/skills/$MAINTAINER/$REPO_NAME" -maxdepth 3 \( -name "SKILL.md" -o -name "README.md" \) -type f | while read f; do
  dir=$(dirname "$f")
  name=$(head -30 "$f" | sed -n "s/^name:[[:space:]]*//p" | head -1)
  desc=$(head -30 "$f" | sed -n "s/^description:[[:space:]]*//p" | head -1)
  if [ -z "$name" ]; then
    name=$(basename "$dir")
  fi
  echo ""
  echo "  📦 Skill: $name"
  echo "     Path: $dir"
  if [ -n "$desc" ]; then
    echo "     Description: $desc"
  fi
done
'
```

### Step 6: Report Results

Present a clear summary to the user:

```
✅ Skills repository installed/updated successfully!

Repository:  <repo-url>
Maintainer:  <maintainer>
Local path:  ~/skills/<maintainer>/<repo-name>
Status:      [Installed|Updated|Already up to date]

Installed skills:
  📦 skill-name-1 — Description of skill 1
  📦 skill-name-2 — Description of skill 2
  📦 skill-name-3 — Description of skill 3
  ...

Total: N skills available

To use a skill, reference it by name: "$ skill-loader <skill-name>"
```

## Directory Structure After Installation

```
~/
└── skills/
    ├── anthropics/                  # Maintainer: anthropics
    │   └── skills/                  # Repo: anthropics/skills
    │       ├── skills/
    │       │   ├── mcp-builder/
    │       │   │   └── SKILL.md
    │       │   ├── skill-creator/
    │       │   │   └── SKILL.md
    │       │   ├── pdf/
    │       │   │   └── SKILL.md
    │       │   └── ...
    │       ├── spec/
    │       ├── template/
    │       └── README.md
    ├── my-repo-owner/               # Maintainer: my-repo-owner
    │   └── ai-tools/                # Repo: my-repo-owner/ai-tools
    │       └── ...
    └── myorg/                       # Maintainer: myorg
        └── custom-skills/            # Repo: myorg/custom-skills
            └── ...
```

## Error Handling

- **Git not installed**: Inform the user that `git` is required and provide install command (`apt install git`, `brew install git`, etc.)
- **Network unreachable**: Check connectivity with `curl -s https://github.com` and report the issue
- **Repository not found**: Verify the URL and inform the user if the repo doesn't exist or is private
- **Directory conflict**: If `~/skills/<maintainer>/<repo-name>` exists but is not a git repo, warn the user and suggest renaming or removing it before cloning
- **Fetch failed**: If the fetch operation fails, the update check is skipped and the current local state is preserved
- **Detached HEAD**: If the repo is in detached HEAD state, `git rev-parse --abbrev-ref HEAD` will fail — the function returns early and skips the update check

## Multiple Repositories

Users can install skills from multiple repositories and maintainers. Each maintainer gets their own directory under `~/skills/`, and each repo gets its own subfolder:

```bash
# Install default Anthropic skills
# → ~/skills/anthropics/skills/
git clone https://github.com/anthropics/skills.git ~/skills/anthropics/skills

# Install a custom skills repo from myorg
# → ~/skills/myorg/custom-skills/
git clone https://github.com/myorg/custom-skills.git ~/skills/myorg/custom-skills

# Install skills from My-Repo-Owner
# → ~/skills/my-repo-owner/ai-tools/
git clone https://github.com/My-Repo-Owner/ai-tools.git ~/skills/my-repo-owner/ai-tools
```

All installed skills are discoverable by the `skill-loader` skill regardless of which repo they came from.

## Convenience: List All Installed Skills

At any time, the user can ask "what skills do I have?" — run the discovery scan across the entire `~/skills/` directory, grouped by maintainer:

```bash
bash -c '
echo "=== All Installed Skills ==="
echo ""
for maintainer_dir in "$HOME/skills"/*/; do
  maintainer=$(basename "$maintainer_dir")
  echo "📂 Maintainer: $maintainer"
  find "$maintainer_dir" -maxdepth 4 \( -name "SKILL.md" -o -name "README.md" \) -type f | while read f; do
    dir=$(dirname "$f")
    name=$(head -30 "$f" | sed -n "s/^name:[[:space:]]*//p" | head -1)
    desc=$(head -30 "$f" | sed -n "s/^description:[[:space:]]*//p" | head -1)
    if [ -z "$name" ]; then
      name=$(basename "$dir")
    fi
    if [ -n "$desc" ]; then
      echo "  📦 $name — $desc"
    else
      echo "  📦 $name — No description"
    fi
  done
  echo ""
done
'
```

## Convenience: Update All Installed Skills

To update all installed skill repos at once (checking commit dates and updating only if remote is newer):

```bash
bash -c '
is_remote_newer() {
  local repo_dir="$1"
  local branch="${2:-main}"
  
  cd "$repo_dir" 2>/dev/null || return 1
  
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
  
  git fetch origin "$branch" 2>/dev/null || return 1
  
  local_local=$(git log -1 --format=%ct HEAD 2>/dev/null)
  local_remote=$(git log -1 --format=%ct "origin/$branch" 2>/dev/null)
  
  [ -n "$local_local" ] && [ -n "$local_remote" ] && [ "$local_remote" -gt "$local_local" ]
}

force_update_repo() {
  local repo_dir="$1"
  
  cd "$repo_dir" 2>/dev/null || return 1
  
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
  
  git fetch origin "$branch" 2>/dev/null || return 1
  git reset --hard "origin/$branch" 2>/dev/null
}

echo "=== Updating all skills ==="
update_count=0
for maintainer_dir in "$HOME/skills"/*/; do
  maintainer=$(basename "$maintainer_dir")
  for repo_dir in "$maintainer_dir"*/; do
    if [ -d "$repo_dir/.git" ]; then
      repo_name=$(basename "$repo_dir")
      if is_remote_newer "$repo_dir"; then
        echo "📦 Updating $maintainer/$repo_name..."
        force_update_repo "$repo_dir"
        ((update_count++)) || true
      else
        echo "✓ $maintainer/$repo_name is up to date"
      fi
    fi
  done
done
echo ""
echo "✅ Updated $update_count repositories"
'
```

## Examples

**Example 1: Default installation**
```
User: "Install the default skills"
→ Clones https://github.com/anthropics/skills.git to ~/skills/anthropics/skills/
→ Discovers and lists all available skills
```

**Example 2: Custom repository**
```
User: "Install skills from https://github.com/myorg/ai-tools.git"
→ Clones https://github.com/myorg/ai-tools.git to ~/skills/myorg/ai-tools/
→ Discovers and lists all available skills
```

**Example 3: Custom repository with mixed-case owner**
```
User: "Install skills from https://github.com/My-Repo-Owner/ai-tools.git"
→ Maintainer slug: my-repo-owner (lowercased)
→ Clones https://github.com/My-Repo-Owner/ai-tools.git to ~/skills/my-repo-owner/ai-tools/
→ Discovers and lists all available skills
```

**Example 4: Update existing skills**
```
User: "Update my skills"
→ Checks each repo under ~/skills/<maintainer>/<repo>/ for newer remote commits
→ Updates only repos where remote HEAD is newer (auto, force update)
→ Reports updated skills per maintainer
```

**Example 5: Install with version check (already installed)**
```
User: "Install skills from https://github.com/anthropics/skills.git"
→ Repository already exists in ~/skills/anthropics/skills/
→ Checks if remote has newer commits than local HEAD
→ If newer: force updates to remote state (discards local changes)
→ If up to date: reports status and skips
```

**Example 6: Default behavior (no URL provided)**
```
User: "Install skills" (no URL)
→ If ~/skills/anthropics/skills/ does not exist: clones the default repo
→ If it exists but remote is newer: updates it
→ Then checks ALL installed repos for updates
→ Updates each repo where remote HEAD is newer than local
→ Reports summary of what was updated
```

**Example 7: List installed skills**
```
User: "What skills do I have installed?"
→ Scans ~/skills/<maintainer>/<repo>/ for all SKILL.md / README.md files
→ Groups results by maintainer
→ Presents a formatted list
```