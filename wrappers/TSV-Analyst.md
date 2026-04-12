---
name: tsv-analyst
description: "Use this skill any time the user wants to perform calculations, aggregations, or statistical analysis on a TSV (or CSV) file and get the results as a structured TSV. Trigger for tasks like: computing totals, averages, percentages, rankings; building KPI summaries or indicator tables from raw data exports; comparing metrics across categories, time periods, or groups; calculating compliance or anomaly rates. Trigger whenever the user uploads or references a TSV/CSV file and wants to derive indicators, metrics, or summaries — even if they don't use 'TSV' or 'calculate'. Also trigger for 'verification file', 'indicator table', or 'KPI summary' requests. The key signal: raw tabular data → computed results the user can trust and verify. Do NOT trigger when the user only wants to view, format, or clean a file, or when the output should be a chart, Word doc, or presentation."
---

# TSV Analyst Skill (Proxy)

This skill is a proxy that delegates to the **tsv-analyst** skill installed in `~/skills/`.

## Activation

When this skill is triggered, load and follow the instructions of the **tsv-analyst** skill located in `~/skills/` using the skill-loader mechanism:

```bash
# Locate the tsv-analyst skill folder
SKILL_PATH=$(find "$HOME/skills" -maxdepth 5 -type d -name "tsv-analyst" | head -1)

# Determine the skill file
if [ -f "$SKILL_PATH/SKILL.md" ]; then
  SKILL_FILE="$SKILL_PATH/SKILL.md"
elif [ -f "$SKILL_PATH/README.md" ]; then
  SKILL_FILE="$SKILL_PATH/README.md"
fi

# Read the full skill instructions
cat "$SKILL_FILE"
```

Then follow all instructions, guidelines, and scripts referenced in the loaded skill as if you had native access to it. The tsv-analyst skill's instructions take priority for any task involving calculations, aggregations, statistical analysis, or KPI summaries from TSV/CSV files.

**Important**: If the skill is not found, inform the user and suggest running the `skill-install` skill first to install the default skills repository.