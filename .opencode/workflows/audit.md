# Workflow: Architectural, Uniformity, and Linguistic Consistency Audit

You must execute this audit process rigorously in the following order.
**ABSOLUTE RULE:** As an audit agent, you must NOT modify ANY source files or configuration files. Your only goal is to produce a report and an action plan.

## Phase 1: Analysis and Extraction (The Scan)
You must perform a **global architectural scan of the entire repository** (not just specific modules unless explicitly requested) using the `@explore` sub-agent.

1. **Determination of the Reference Norm**: Identify the majority architectural **intent** (e.g., "Files organized by feature" or "Layered architecture") and extract general consistency patterns. Also identify the **Data Flow Paradigm** (e.g., Unidirectional, Event-Driven, MVC) and **State Management Strategy**.
2. **Uniformity and Consistency Audit**:
   - **Architecture & Style**: Strictly compare the file structure and global style against the intentional Reference Norm.
   - **Design Pattern Identification**: Identify recurring architectural design patterns (e.g., Singleton, Factory, Repository, MVVM, Hexagonal/Clean Architecture, Dependency Injection). Map how responsibilities are delegated between layers.
   - **Coupling, Cohesion & Boundaries**: Evaluate module coupling. Actively scan for anti-patterns such as cyclic dependencies, 'God Objects', or violations of the Single Responsibility Principle (SRP).
   - **Interface & API Contracts**: Audit boundary contracts. Ensure communication between distinct architectural layers uses consistent interfaces/DTOs. Flag direct undocumented deep-linking between disparate modules.
   - **Complexity Metrics**: Identify modules with high cyclomatic complexity or excessively large files that degrade architectural health.
   - **Linguistic Audit**: Analyze natural language consistency separately for 3 categories: code language (variables, functions), comment language, and documentation language. Ensure that only one language is used uniformly within each category.
   - **Tests**: Identify the global testing strategy (e.g., "Systematic unit testing") without being tied to a specific framework or extension.

## Phase 2: Generation of Deliverables
Generate your response by clearly presenting the following two deliverables:

**Deliverable A: The Audit Report (Macro)**
- **Architectural Health Score**: Provide a score out of 100 for architectural integrity (design patterns, coupling, boundaries, complexity).
- **Uniformity Score**: Provide a score out of 100 calculated on the ratio of files/functions respecting the linguistic consistency.
- **OK / KO Mapping**: An analytical summary listing the folders/modules perfectly aligned (OK) and those presenting architectural, stylistic, or linguistic deviations (KO).

**Deliverable B: The Remediation Plan (Micro)**
- **Phase 1 - Issue Inventory**: List **EVERY** detected architectural and structural violation separately. For each issue, specify: the target file/module, the detected anomaly (architectural, stylistic, or linguistic), and the exact majority pattern/language to apply.
- **Phase 2 - Execution Plan**: Provide a structured, step-by-step action plan designed as a "brief" for an agent in Code mode to systematically fix all listed issues.

## Phase 3: Consolidation of AGENTS.MD (The Learning Loop)
The **very first task** of your Remediation Plan (Deliverable B) MUST BE the update of the `AGENTS.MD` (or `agents.md`) file. You must prepare the exact instructions for the Code agent according to these **absolute cross-compatibility** rules:
1. **Architectural Guardrails**: Extract rules regarding **Layered Boundaries** (e.g., "UI must not access DB directly"), **Pattern Enforcement** (e.g., "External integrations must use the Repository pattern"), and **Dependency Direction Rules** (e.g., "Domain logic cannot depend on infrastructure details").
2. **Total Abstraction**: Translate each detected anomaly into a fundamental principle. Use exclusively generic terms ("source files", "test files", "nomenclature").
3. **Prohibition of Specifics**: **NEVER** mention file extensions (`.ts`, `.py`, `.go`, etc.), specific test framework names, or language-specific typing rules. The rules must be valid for any codebase (Java, Python, Go, etc.).
4. **Repo Specifics**: In this section of `AGENTS.MD`, document high-level architecture, general consistency directives, and the architectural guardrails extracted in step 1 (e.g., "PascalCase for data types", "Uniform service suffixes").
5. **Portability Validation**: Before proposing the modification, review your new rules and validate that they contain no "scoria" related to the current language of the repo.
6. **Negative Prompting & Fusion**: Formulate as a strict prohibition (`NEVER...`, `DO NOT...`). Explicitly ask the Code agent to merge intelligently, avoiding redundancies.
