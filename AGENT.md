# AGENT.md

## Language Policy

**All files in this repository MUST be written in English.**

This includes:
- Skill content (`SKILL.md`, `README.md`)
- Code comments
- Documentation
- Commit messages
- Variable names, file names

Interactions with the repository maintainer may be in French, but nothing is written or persisted in any language other than English.

## Purpose of this Repository

Development and maintenance repository for OpenWebUI skills in markdown format. Skills produced here are meant to be installed on target machines (in `~/skills/`) and used via OpenWebUI.

## Structure

```
<skill-name>/SKILL.md       # Native skills developed in this repo
wrappers/<Name>.md          # Wrappers ready to import into OpenWebUI
docs/                       # Technical documentation
```

## CRITICAL Constraints

### 1. Mandatory Frontmatter
Every skill MUST have a YAML frontmatter:
```yaml
---
name: skill-id
description: "Precise description that TRIGGERS the skill"
---
```
**The `description` is the trigger** — it determines when the skill activates automatically. Without a relevant description, the skill will never be invoked.

### 2. Wrappers = Importable Proxies
Wrappers in `wrappers/` are markdown files ready to be imported into OpenWebUI. They proxy to a skill installed in `~/skills/` on the target machine.

**Two wrapper creation scenarios:**

| Case | Source | Required Data |
|------|--------|---------------|
| Skill from this repo | `mermaid/`, `tsv-analyst/`, etc. | Read `SKILL.md` to extract `name` and `description` |
| External skill | Not present in this repo | User provides `name` and `description` |

### 3. Prohibitions
- **NEVER** modify an existing `description` without understanding the impact on triggering
- **NEVER** create a skill without a dedicated folder containing `SKILL.md`
- **NEVER** put temporary work files in this repo
- **NEVER** reference `~/skills/` in the skill logic itself (only in wrappers)

## Creating a New Skill

1. Create a folder `<skill-name>/`
2. Create `SKILL.md` with complete frontmatter
3. `description` = when to use (trigger)
4. Markdown body = how the skill works

## Creating a Wrapper

### Case 1: Skill present in this repo
1. Read `<skill-name>/SKILL.md`
2. Extract `name` and `description` from frontmatter
3. Generate wrapper using the proxy template

### Case 2: External skill (not in this repo)
1. Ask user for `name` and `description`
2. Generate wrapper using the proxy template

## Skill Validation

Before considering a skill complete, verify:

- [ ] Valid YAML frontmatter (`name` + `description`)
- [ ] Description describes **when** to use, not how
- [ ] Description covers obvious use cases AND alternative phrasings
- [ ] Skill body contains executable instructions
- [ ] No hardcoded paths specific to a particular machine
- [ ] If skill uses reference files, they are in `<skill-name>/references/`

### Description Test
The description must answer: "If a user says X, should this skill trigger?"
- If answer is "yes" and X is not covered → add X to the description
- If answer is "maybe" → clarify or broaden the description