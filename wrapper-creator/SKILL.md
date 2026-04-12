---
name: wrapper-creator
description: Create a skill wrapper JSON that proxies to an installed skill in ~/skills/. Use when the user wants to generate a wrapper for a skill they use frequently, so they don't have to go through skill-loader each time. The user provides a skill name (the same name they would give to skill-loader), and this skill produces a complete JSON wrapper file that can be imported directly. Trigger this skill whenever the user mentions creating a wrapper, wrapping a skill, generating a skill proxy, or making a skill shortcut, even if they don't explicitly say "wrapper creator".
---

# Wrapper Creator

Create a skill wrapper JSON that acts as a lightweight proxy to an installed skill in `~/skills/`. This lets you use frequently-needed skills directly without loading them through `skill-loader` every time.

## What It Does

Given a **skill name** (the same name you'd pass to `skill-loader`), this skill:

1. **Locates the target skill** in `~/skills/` to read its description
2. **Generates a complete wrapper JSON** that can be imported as a standalone skill
3. **The wrapper is a proxy** — when triggered, it loads the real skill from `~/skills/` and delegates to it

## Wrapper Pattern

Every wrapper follows this exact pattern, modeled after the xlsx, pptx, and docx wrappers:

- **`id`**: Same as the target skill name (e.g., `xlsx`, `pptx`, `docx`)
- **`name`**: Capitalized version of the skill name (e.g., `Xlsx`, `Pptx`, `Docx`)
- **`description`**: The description is taken from the target skill's `SKILL.md` or `README.md` frontmatter. If not found, the user must provide it.
- **`content`** (SKILL.md body): A proxy template that loads the real skill from `~/skills/`

## Step-by-Step Instructions

### Step 1: Get the Target Skill Name

Ask the user which skill they want to wrap. This is the same name they would give to `skill-loader`.

Examples: `xlsx`, `pptx`, `docx`, `pdf`, `mcp-builder`, `skill-creator`, etc.

### Step 2: Locate the Target Skill and Read Its Description

Search for the skill in `~/skills/` and extract its description:

```bash
SKILL_NAME="<user-provided-name>"
SKILL_PATH=""

# Strategy 1: Exact match on folder name
SKILL_PATH=$(find "$HOME/skills" -maxdepth 5 -type d -name "$SKILL_NAME" | head -1)

# Strategy 2: Match on YAML frontmatter name field
if [ -z "$SKILL_PATH" ]; then
  while IFS= read -r mdfile; do
    md_name=$(head -30 "$mdfile" | sed -n 's/^name:[[:space:]]*//p' | head -1)
    if [ "$md_name" = "$SKILL_NAME" ]; then
      SKILL_PATH=$(dirname "$mdfile")
      break
    fi
  done < <(find "$HOME/skills" -maxdepth 5 \( -name "SKILL.md" -o -name "README.md" \) -type f)
fi

# Strategy 3: Partial/fuzzy match
if [ -z "$SKILL_PATH" ]; then
  SKILL_PATH=$(find "$HOME/skills" -maxdepth 5 -type d -name "*$SKILL_NAME*" | head -1)
fi

if [ -n "$SKILL_PATH" ]; then
  # Read the skill file
  if [ -f "$SKILL_PATH/SKILL.md" ]; then
    SKILL_FILE="$SKILL_PATH/SKILL.md"
  elif [ -f "$SKILL_PATH/README.md" ]; then
    SKILL_FILE="$SKILL_PATH/README.md"
  fi

  # Extract description from frontmatter
  DESCRIPTION=$(head -30 "$SKILL_FILE" | sed -n 's/^description:[[:space:]]*//p' | head -1)

  echo "Found skill at: $SKILL_PATH"
  echo "Description: $DESCRIPTION"
else
  echo "Skill not found in ~/skills/"
fi
```

**If the skill is not found**, ask the user to either:
- Install it first using `skill-install`
- Provide the description manually

### Step 3: Generate the Wrapper JSON

Construct the wrapper JSON using the template below. Replace all `<placeholders>` with actual values:

```json
[
  {
    "id": "<skill-name>",
    "user_id": "<leave-as-is-or-remove>",
    "name": "<Skill-Name>",
    "description": "<description-from-step-2>",
    "meta": { "tags": [] },
    "is_active": true,
    "access_grants": [],
    "updated_at": <current-unix-timestamp>,
    "created_at": <current-unix-timestamp>,
    "user": null,
    "write_access": true,
    "content": "---\nname: <skill-name>\ndescription: \"<description-from-step-2>\"\n---\n\n# <Skill-Name> Skill (Proxy)\n\nThis skill is a proxy that delegates to the **<skill-name>** skill installed in `~/skills/`.\n\n## Activation\n\nWhen this skill is triggered, load and follow the instructions of the **<skill-name>** skill located in `~/skills/` using the skill-loader mechanism:\n\n```bash\n# Locate the <skill-name> skill folder\nSKILL_PATH=$(find \"$HOME/skills\" -maxdepth 5 -type d -name \"<skill-name>\" | head -1)\n\n# Determine the skill file\nif [ -f \"$SKILL_PATH/SKILL.md\" ]; then\n  SKILL_FILE=\"$SKILL_PATH/SKILL.md\"\nelif [ -f \"$SKILL_PATH/README.md\" ]; then\n  SKILL_FILE=\"$SKILL_PATH/README.md\"\nfi\n\n# Read the full skill instructions\ncat \"$SKILL_FILE\"\n```\n\nThen follow all instructions, guidelines, and scripts referenced in the loaded skill as if you had native access to it. The <skill-name> skill's instructions take priority for any task involving <brief-topic-summary>.\n\n**Important**: If the skill is not found, inform the user and suggest running the `skill-install` skill first to install the default Anthropic skills repository."
  }
]
```

### Step 4: Handle the `name` Field Capitalization

The `name` field in the JSON should be a human-friendly capitalized version of the skill id:

| Skill ID (id) | Display Name (name) |
|----------------|---------------------|
| `xlsx` | `Xlsx` |
| `pptx` | `Pptx` |
| `docx` | `Docx` |
| `pdf` | `Pdf` |
| `mcp-builder` | `Mcp Builder` |
| `skill-creator` | `Skill Creator` |
| `skill-loader` | `Skill Loader` |
| `skill-install` | `Skill Install` |

**Rule**: Split on hyphens, capitalize the first letter of each word, join with spaces.

### Step 5: Handle the Description

The `description` field should be extracted from the target skill's `SKILL.md` or `README.md` YAML frontmatter. This ensures the wrapper triggers in exactly the same situations as the original skill.

**If the description is not available** (skill not installed or no frontmatter), ask the user to provide a description, or generate one based on the skill name.

### Step 6: Save the Wrapper JSON

Save the generated wrapper to a file:

```bash
# Save to the wrappers directory
mkdir -p "$HOME/wrappers"
echo '<wrapper-json>' > "$HOME/wrappers/skill-<skill-name>-wrapper.json"
```

Report the saved file path to the user:

```
✅ Wrapper created successfully!

Skill: <skill-name>
Name: <Skill Name>
File: ~/wrappers/skill-<skill-name>-wrapper.json

The wrapper proxies to the <skill-name> skill installed in ~/skills/.
Import this JSON file to add the wrapper skill.
```

## JSON Escaping Rules

When generating the JSON, special characters in the `content` field must be properly escaped:

| Character | Escape Sequence |
|-----------|----------------|
| `"` | `\"` |
| `\` | `\\` |
| Newline | `\n` |
| Tab | `\t` |

The `description` field (both in the top-level JSON and in the YAML frontmatter inside `content`) must also be properly escaped.

## Examples

### Example 1: Wrapper for `pdf`

User asks: *"Crée un wrapper pour pdf"*

Generated JSON:
```json
[
  {
    "id": "pdf",
    "name": "Pdf",
    "description": "Use this skill whenever the user wants to do anything with PDF files. This includes reading or extracting text/tables from PDFs, combining or merging multiple PDFs into one, splitting PDFs apart, rotating pages, adding watermarks, creating new PDFs, filling PDF forms, encrypting/decrypting PDFs, extracting images, and OCR on scanned PDFs to make them searchable. If the user mentions a .pdf file or asks to produce one, use this skill.",
    "meta": { "tags": [] },
    "is_active": true,
    "access_grants": [],
    "updated_at": 1775851300,
    "created_at": 1775851300,
    "user": null,
    "write_access": true,
    "content": "---\nname: pdf\ndescription: \"Use this skill whenever the user wants to do anything with PDF files...\"\n---\n\n# Pdf Skill (Proxy)\n\nThis skill is a proxy that delegates to the **pdf** skill installed in `~/skills/`.\n\n## Activation\n\nWhen this skill is triggered, load and follow the instructions of the **pdf** skill located in `~/skills/` using the skill-loader mechanism:\n\n```bash\nSKILL_PATH=$(find \"$HOME/skills\" -maxdepth 5 -type d -name \"pdf\" | head -1)\n\nif [ -f \"$SKILL_PATH/SKILL.md\" ]; then\n  SKILL_FILE=\"$SKILL_PATH/SKILL.md\"\nelif [ -f \"$SKILL_PATH/README.md\" ]; then\n  SKILL_FILE=\"$SKILL_PATH/README.md\"\nfi\n\ncat \"$SKILL_FILE\"\n```\n\nThen follow all instructions, guidelines, and scripts referenced in the loaded skill as if you had native access to it. The pdf skill's instructions take priority for any task involving PDF files.\n\n**Important**: If the skill is not found, inform the user and suggest running the `skill-install` skill first to install the default Anthropic skills repository."
  }
]
```

### Example 2: Wrapper for `mcp-builder`

User asks: *"Create a wrapper for mcp-builder"*

The same pattern applies — id stays `mcp-builder`, name becomes `Mcp Builder`, description is pulled from the skill's frontmatter, and the proxy content follows the same template.

### Example 3: Skill not yet installed

If the user asks for a wrapper for a skill that isn't in `~/skills/` yet:

```
⚠️ Skill 'quantum-computing' not found in ~/skills/

Options:
1. Install it first using skill-install, then generate the wrapper
2. Provide a description manually and I'll generate the wrapper anyway

Which would you prefer?
```

## Batch Mode

If the user wants wrappers for multiple skills at once (e.g., *"crée des wrappers pour xlsx, pptx et docx"*), generate each wrapper JSON separately and save them as individual files:

```
~/wrappers/skill-xlsx-wrapper.json
~/wrappers/skill-pptx-wrapper.json
~/wrappers/skill-docx-wrapper.json
```

Or combine them into a single JSON array if preferred:

```json
[
  { ... xlsx wrapper ... },
  { ... pptx wrapper ... },
  { ... docx wrapper ... }
]
```

Ask the user which format they prefer.

## Difference from skill-loader

| Aspect | skill-loader | Wrapper |
|--------|-------------|---------|
| Purpose | Dynamically load any skill by name at runtime | Permanent lightweight proxy for frequently-used skills |
| Triggering | Must be explicitly invoked | Auto-triggers based on its description |
| Overhead | Search + read every time | Direct delegation, no search needed |
| Use case | Infrequent or one-off skills | Skills used often (xlsx, pdf, pptx, etc.) |

Wrappers are ideal for skills you use all the time — they auto-trigger from their description and immediately delegate to the installed skill, without needing to go through skill-loader.