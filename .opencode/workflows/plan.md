# Workflow: Detailed Planning

You must execute this planning process rigorously in the following order.

## Step 1: Codebase Exploration
Use the `@explore` sub-agent with **medium** depth to analyze the codebase (search for relevant keywords, identification of the general architecture and languages/frameworks used).

## Step 2: Documentation Exploration
Use the `@explore` sub-agent to analyze the `docs/` folder.
*Note: If the sub-agent determines that no `docs` folder exists, briefly notify the user and proceed immediately to the next step.*

## Step 3: Knowledge Update (Context7 MCP)
Deduce the libraries, frameworks, and technologies used from the exploration in Step 1 (in an agnostic manner, for example via `Cargo.toml`, `go.mod`, `requirements.txt`, `package.json`, etc.). Then **silently** query the Context7 MCP to update your knowledge on the identified technical documentations.

## Step 4: Clarification (@questioning)
Imperatively use the `@questioning` tag (which references `.opencode/skills/questioning/SKILL.md`) to ask 7 very relevant and contextualized questions regarding your findings in the code and documentation.
**ATTENTION: Stop here and wait for the user's answers.**

## Step 5: Plan Proposal
Only AFTER obtaining the user's answers, propose a detailed step-by-step implementation plan.

## Step 6: Transition
If the proposed plan requires no adjustment from the user, display EXACTLY the following message:
"Switch to Code mode to validate and execute this detailed plan."
