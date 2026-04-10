# Mermaid Syntax Reference

Complete Mermaid syntax reference covering all diagram types with common patterns and pitfalls.

---

## General Rules

### Node IDs
- Must start with a letter (not a number)
- Can contain letters, numbers, underscores, hyphens
- Cannot contain spaces — use labels instead
- Case-sensitive

### Labels
- Wrap in quotes if containing special characters: `A["Label with (parens)"]`
- Use `<br/>` for line breaks in labels: `A["Line 1<br/>Line 2"]`
- Unicode is supported in labels

### Comments
- `%% This is a comment` — single line
- Comments are not rendered

### Semicolons
- Optional in flowcharts and sequence diagrams
- Required between statements in some contexts

---

## Flowchart Syntax Deep Dive

### Declaration
```
flowchart TD
```
Use `TD`, `TB`, `BT`, `LR`, or `RL` for direction.

### Node Definitions
```
A[Rectangle]
B(Rounded Rectangle)
C{Diamond}
D([Stadium])
E[[Subprocess]]
F[(Database)]
G((Circle))
H{{Hexagon}}
I[/Parallelogram/]
J[\Trapezoid\]
K>Asymmetric]
```

### Edge Definitions
```
A --> B          %% Arrow
A --- B          %% Line
A -.-> B         %% Dotted arrow
A ==> B          %% Thick arrow
A --text--> B    %% Inline label
A -->|text| B    %% Label on arrow
A & B --> C      %% Multiple sources
A --> B & C      %% Multiple targets
```

### Subgraphs
```
subgraph id [Title]
    A --> B
end
```
Subgraphs can be nested. Use `direction LR` inside subgraphs.

### Styling
```
classDef className fill:#color,stroke:#color,color:#color,stroke-width:2px
class nodeId className
class A,B,C className
linkStyle 0 stroke:#color,stroke-width:2px
```

### Click Events
```
click A callback "Tooltip"
click B href "https://example.com" "Tooltip"
```

---

## Sequence Diagram Syntax Deep Dive

### Declaration
```
sequenceDiagram
```

### Participants
```
actor User
participant Server as "API Server"
participant DB
```

### Messages
```
A->>B: Sync message
A-->>B: Async response
A-)B: Async open arrow
B--xA: Failed message
B--)A: Dotted open arrow
```

### Blocks
```
alt Condition 1
    A->>B: Action
else Condition 2
    A->>B: Other action
end

opt Optional action
    A->>B: May or may not happen
end

loop Every 30 seconds
    A->>B: Heartbeat
end

par Parallel action 1
    A->>B: Action 1
and Parallel action 2
    A->>B: Action 2
end

critical Must succeed
    A->>B: Critical action
option Fallback
    A->>B: Recovery
end
```

### Notes and Highlights
```
Note over A,B: Note spanning participants
Note right of A: Note next to A

rect rgb(200, 220, 255)
    A->>B: Highlighted section
end
```

### Activation
```
activate A
A->>B: Request
deactivate A
%% Or shorthand:
A->>+B: Request (activates B)
B-->>-A: Response (deactivates B)
```

---

## Class Diagram Syntax Deep Dive

### Declaration
```
classDiagram
```

### Class Definition
```
class ClassName {
    <<stereotype>>
    +publicField: Type
    -privateField: Type
    #protectedField: Type
    +publicMethod() ReturnType
    -privateMethod(param: Type) ReturnType
    +staticMethod()$ ReturnType
}
```

### Relationships
```
ClassA <|-- ClassB : extends (inheritance)
ClassA <|.. ClassB : implements (realization)
ClassA --> ClassB : uses (association)
ClassA --* ClassB : contains (composition)
ClassA --o ClassB : aggregates (aggregation)
ClassA ..> ClassB : depends on (dependency)
```

### Labels and Cardinality
```
ClassA "1" --> "*" ClassB : has many
ClassA "1..*" --> "0..1" ClassB : optional
```

### Namespaces
```
namespace Models {
    class User
    class Order
}
```

### Direction
```
direction LR  %% or TB
```

---

## ER Diagram Syntax Deep Dive

### Declaration
```
erDiagram
```

### Entities and Attributes
```
ENTITY_NAME {
    type field_name KEY_TYPE
}
```
Types: `int`, `string`, `float`, `date`, `boolean`, `decimal`, `text`, `json`, `uuid`

Key types: `PK` (primary), `FK` (foreign), `UK` (unique)

### Relationships
```
ENTITY_A CARDINALITY_A -- CARDINALITY_B ENTITY_B : "relationship"
```

Cardinality markers:
- `||` — Exactly one
- `|o` — Zero or one  
- `|{` — One or more (required)
- `o{` — Zero or more (optional)

---

## State Diagram Syntax Deep Dive

### Declaration
```
stateDiagram-v2
```

### States and Transitions
```
[*] --> StateA
StateA --> StateB : trigger / action
StateB --> [*]
```

### Composite States
```
state StateA {
    [*] --> SubState1
    SubState1 --> SubState2 : next
}
```

### Fork/Join
```
state fork_state <<fork>>
state join_state <<join>>

StateA --> fork_state
fork_state --> StateB
fork_state --> StateC
StateB --> join_state
StateC --> join_state
join_state --> StateD
```

### Concurrent States
```
state ConcurrentStates {
    state Region1 {
        [*] --> S1
        S1 --> S2
    }
    --
    state Region2 {
        [*] --> S3
        S3 --> S4
    }
}
```

### Notes
```
note left of StateA : Description
note right of StateB : Description
```

---

## Gantt Chart Syntax Deep Dive

### Declaration
```
gantt
    title Project Name
    dateFormat YYYY-MM-DD
    axisFormat %b %d
```

### Tasks
```
section Section Name
    Task Label :task_id, start_date, duration
    Task Label :task_id, after other_task, duration
    Task Label :task_id, start_date, end_date
```

### Modifiers
- `:active` — Currently in progress
- `:done` — Completed
- `:crit` — On critical path
- `:milestone` — Milestone (0 duration)

### Excludes
```
excludes weekends
excludes 2024-12-25
```

---

## Common Pitfalls and Solutions

### 1. Node IDs with special characters
**Wrong**: `node with spaces --> another node`
**Right**: `node_with_spaces["Node with spaces"] --> another_node["Another node"]`

### 2. Missing quotes on labels with parentheses
**Wrong**: `A[Label (detail)]`
**Right**: `A["Label (detail)"]`

### 3. Circular dependencies in flowcharts
If edges create a tangled mess, consider:
- Using `direction LR` to change layout
- Splitting into subgraphs
- Removing less important edges
- Creating a separate detail diagram

### 4. Sequence diagram ordering
Messages must appear in the order they happen. You cannot reference a participant before declaring it (unless using `autonumber`).

### 5. Class diagram method syntax
**Wrong**: `+method`
**Right**: `+method() void` or `+method(param: Type) ReturnType`

### 6. ER diagram relationship direction
The first entity is on the left side of the relationship, the second on the right. Cardinality markers go next to their respective entity:
```
CUSTOMER ||--o{ ORDER : "places"
%% One customer places zero or more orders
```

### 7. State diagram initial/final states
Always include `[*]` for start and end states. Without them, the diagram is incomplete.

### 8. Subgraph direction in flowcharts
```
subgraph id [Title]
    direction LR  %% This affects only this subgraph
    A --> B
end
```

### 9. Escaping in labels
Use `#` to escape special characters: `#quot;` for `"`, `#lt;` for `<`, `#gt;` for `>`, `#amp;` for `&`

### 10. Long labels
Break long labels with `<br/>`:
```
A["This is a very long label<br/>that wraps to a second line"]
```

---

## Mermaid Configuration Options

When initializing Mermaid in HTML:

```javascript
mermaid.initialize({
    startOnLoad: true,
    theme: 'default',  // 'default', 'dark', 'forest', 'neutral', 'null'
    themeVariables: {
        primaryColor: '#4A90D9',
        primaryTextColor: '#fff',
        primaryBorderColor: '#2C5F8A',
        lineColor: '#666',
        secondaryColor: '#7ED321',
        tertiaryColor: '#F5A623',
        fontSize: '16px',
    },
    flowchart: {
        htmlLabels: true,
        curve: 'basis',
        rankSpacing: 50,
        nodeSpacing: 30,
    },
    sequence: {
        diagramMarginX: 50,
        diagramMarginY: 10,
        actorMargin: 50,
        width: 150,
        height: 65,
        mirrorActors: true,
        useMaxWidth: true,
    },
    themeCSS: '.label { font-size: 14px; }',
});
```

---

## Performance Tips

1. **Keep diagrams under 300 nodes** — beyond this, rendering becomes slow
2. **Use `direction`** to control layout instead of relying on automatic placement
3. **Avoid excessive cross-links** — if nodes have >5 connections, consider splitting the diagram
4. **Use subgraphs** to logically group nodes and improve layout
5. **Prefer `flowchart` over `graph`** — `flowchart` is the newer, more capable syntax