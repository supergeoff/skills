---
name: mermaid
description: "Create rigorous, precise diagrams (flowcharts, sequence diagrams, class diagrams, state diagrams, ER diagrams, Gantt charts, pie charts, mindmaps, architecture diagrams, etc.) from text descriptions, specifications, code, or any textual input. Generate output as standalone HTML files with embedded Mermaid.js rendering, or raw Mermaid code blocks. Use this skill whenever the user wants to visualize relationships, processes, systems, data models, workflows, architectures, or any structured information — even if they don't explicitly mention 'diagram' or 'mermaid'. Also use when users ask to 'draw', 'map', 'visualize', 'chart', 'illustrate', or 'show how X works'."
---

# Mermaid Diagram Builder Skill (Proxy)

This skill is a proxy that delegates to the **mermaid** skill installed in `~/skills/`.

## Activation

When this skill is triggered, load and follow the instructions of the **mermaid** skill located in `~/skills/` using the skill-loader mechanism:

```bash
# Locate the mermaid skill folder
SKILL_PATH=$(find "$HOME/skills" -maxdepth 5 -type d -name "mermaid" | head -1)

# Determine the skill file
if [ -f "$SKILL_PATH/SKILL.md" ]; then
  SKILL_FILE="$SKILL_PATH/SKILL.md"
elif [ -f "$SKILL_PATH/README.md" ]; then
  SKILL_FILE="$SKILL_PATH/README.md"
fi

# Read the full skill instructions
cat "$SKILL_FILE"
```

Then follow all instructions, guidelines, and scripts referenced in the loaded skill as if you had native access to it. The mermaid skill's instructions take priority for any task involving diagram creation, visualization, flowcharts, sequence diagrams, or any structured visual representation.

**Important**: If the skill is not found, inform the user and suggest running the `skill-install` skill first to install the default Anthropic skills repository.