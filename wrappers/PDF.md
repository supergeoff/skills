---
name: pdf
description: Use this skill whenever the user wants to do anything with PDF files. This includes reading or extracting text/tables from PDFs, combining or merging multiple PDFs into one, splitting PDFs apart, rotating pages, adding watermarks, creating new PDFs, filling PDF forms, encrypting/decrypting PDFs, extracting images, and OCR on scanned PDFs to make them searchable. If the user mentions a .pdf file or asks to produce one, use this skill.
---

# PDF Skill (Proxy)

This skill is a proxy that delegates to the **pdf** skill installed in `~/skills/`.

## Activation

When this skill is triggered, load and follow the instructions of the **pdf** skill located in `~/skills/` using the skill-loader mechanism:

```bash
# Locate the pdf skill folder
SKILL_PATH=$(find "$HOME/skills" -maxdepth 4 -type d -name "pdf" | head -1)

# Determine the skill file
if [ -f "$SKILL_PATH/SKILL.md" ]; then
  SKILL_FILE="$SKILL_PATH/SKILL.md"
elif [ -f "$SKILL_PATH/README.md" ]; then
  SKILL_FILE="$SKILL_PATH/README.md"
fi

# Read the full skill instructions
cat "$SKILL_FILE"
```

Then follow all instructions, guidelines, and scripts referenced in the loaded skill as if you had native access to it. The pdf skill's instructions take priority for any task involving PDF files.

**Important**: If the skill is not found, inform the user and suggest running the `skill-install` skill first to install the default Anthropic skills repository.