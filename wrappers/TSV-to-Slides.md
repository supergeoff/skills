---
name: tsv-to-slides
description: "Use this skill any time the user wants to transform a TSV or CSV file into a visual HTML slide deck — one slide per indicator, formatted for 16:9 print-to-PDF or import into Google Slides / PowerPoint. Trigger whenever the user mentions: 'slides', 'présentation', 'HTML', 'diapositives', 'rapport visuel', 'dashboard', 'mise en forme', 'visualiser mes données', or when they upload a TSV/CSV and want something visual out of it — even if they say 'PowerPoint', 'PDF', 'deck', or 'pitch'. Also trigger when the output of tsv-analyst needs to be visualised. This skill is particularly important to use when the user has just finished a tsv-analyst run and wants to present the results."
---

# TSV to Slides Skill (Proxy)

This skill is a proxy that delegates to the **tsv-to-slides** skill installed in `~/skills/`.

## Activation

When this skill is triggered, load and follow the instructions of the **tsv-to-slides** skill located in `~/skills/` using the skill-loader mechanism:

```bash
# Locate the tsv-to-slides skill folder
SKILL_PATH=$(find "$HOME/skills" -maxdepth 5 -type d -name "tsv-to-slides" | head -1)

# Determine the skill file
if [ -f "$SKILL_PATH/SKILL.md" ]; then
  SKILL_FILE="$SKILL_PATH/SKILL.md"
elif [ -f "$SKILL_PATH/README.md" ]; then
  SKILL_FILE="$SKILL_PATH/README.md"
fi

# Read the full skill instructions
cat "$SKILL_FILE"
```

Then follow all instructions, guidelines, and scripts referenced in the loaded skill as if you had native access to it. The tsv-to-slides skill's instructions take priority for any task involving HTML slide generation, data visualization, dashboards, or presentations from TSV/CSV files.

**Important**: If the skill is not found, inform the user and suggest running the `skill-install` skill first to install the default skills repository.