# Mermaid Diagram Types — Complete Reference

This document catalogs all Mermaid diagram types with syntax, use cases, and examples.

---

## 1. Flowchart (`flowchart`)

**When to use**: Process flows, decision trees, workflows, algorithms, system logic, data pipelines.

**Key advantage**: Most versatile diagram type. Supports subgraphs, styling, and multiple layout directions.

```mermaid
flowchart TD
    A([Start]) --> B[Process Input]
    B --> C{Is Valid?}
    C -->|Yes| D[Execute Action]
    C -->|No| E[Return Error]
    D --> F[(Save to DB)]
    F --> G([End])
    E --> G
```

**Node shapes**:
- `[A]` — Rectangle (process)
- `(A)` — Rounded rectangle (start/end)
- `{A}` — Diamond (decision)
- `([A])` — Stadium/pill shape
- `[[A]]` — Subprocess
- `[(A)]` — Cylinder (database)
- `((A))` — Circle
- `{{A}}` — Hexagon
- `>A]` — Asymmetric (flag right)
- `[A/]` — Parallelogram (input/output)

**Edge types**:
- `-->` — Arrow with line
- `---` — Line without arrow
- `-.->` — Dotted arrow
- `==>` — Thick arrow
- `-->|text|` — Arrow with label
- `--text-->` — Arrow with inline label

**Directions**: `TD` (top-down), `TB` (top-bottom = TD), `BT` (bottom-top), `LR` (left-right), `RL` (right-left)

**Subgraphs**: Group related nodes
```mermaid
flowchart LR
    subgraph grp_frontend [Frontend]
        A[UI] --> B[API Client]
    end
    subgraph grp_backend [Backend]
        C[API Server] --> D[Database]
    end
    B --> C
```

---

## 2. Sequence Diagram (`sequenceDiagram`)

**When to use**: Interactions between actors/systems over time, API call flows, protocol exchanges, user journeys with system touchpoints.

**Key advantage**: Shows temporal ordering and message passing clearly.

```mermaid
sequenceDiagram
    autonumber
    actor Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant DB as Database
    
    Client->>API: POST /login
    API->>Auth: validate(credentials)
    Auth->>DB: lookupUser(email)
    DB-->>Auth: userRecord
    alt Valid credentials
        Auth-->>API: JWT token
        API-->>Client: 200 OK
    else Invalid credentials
        Auth-->>API: 401 Unauthorized
        API-->>Client: 401 Unauthorized
    end
```

**Key syntax**:
- `actor A` — Stick figure
- `participant A` — Rectangle
- `participant A as "Long Name"` — With alias
- `A->>B` — Solid arrow (request)
- `A-->>B` — Dashed arrow (response)
- `A-)B` — Open arrow (async)
- `alt/else/end` — Conditional
- `opt/end` — Optional
- `loop/end` — Iteration
- `par/and/end` — Parallel
- `critical/option/end` — Critical section
- `Note over A,B: text` — Annotation
- `rect rgb(r,g,b)` — Background highlight
- `activate A` / `deactivate A` — Show lifeline activation

---

## 3. Class Diagram (`classDiagram`)

**When to use**: Object-oriented design, database schema visualization, API models, domain modeling.

```mermaid
classDiagram
    class Animal {
        <<abstract>>
        +String name
        +int age
        +makeSound()* void
    }
    class Dog {
        +String breed
        +fetch() void
        +makeSound() void
    }
    class Cat {
        +bool indoor
        +purr() void
        +makeSound() void
    }
    class Owner {
        +String name
        +feedPet() void
    }
    
    Animal <|-- Dog : extends
    Animal <|-- Cat : extends
    Dog --> Owner : belongs to
    Cat --> Owner : belongs to
```

**Key syntax**:
- Visibility: `+` public, `-` private, `#` protected, `~` package/internal
- `<<interface>>` / `<<abstract>>` — Stereotypes
- `<|--` — Inheritance
- `-->` — Association
- `--*` — Composition
- `--o` — Aggregation
- `..>` — Dependency
- `..|>` — Realization (implements)
- `namespace` — Grouping
- `direction LR` or `direction TB` — Layout direction

**Relationship cardinalities**:
- `A "1" --> "1" B` — One to one
- `A "1" --> "*" B` — One to many
- `A "1" --> "0..1" B` — One to zero-or-one
- `A "*" --> "*" B` — Many to many

---

## 4. State Diagram (`stateDiagram-v2`)

**When to use**: State machines, order statuses, workflow states, protocol states, lifecycle modeling.

```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Review : submit
    Review --> Approved : approve
    Review --> Rejected : reject
    Rejected --> Draft : revise
    Approved --> Published : publish
    Published --> Archived : archive
    Archived --> [*]
    
    state Review {
        [*] --> PeerReview
        PeerReview --> ManagerReview : peer approved
        ManagerReview --> [*] : manager approved
    }
```

**Key syntax**:
- `[*]` — Initial/final state
- `A --> B : trigger` — Transition with label
- `state A { }` — Composite/nested state
- `note left of A: text` — Annotation
- `direction LR` / `direction TB` — Layout

---

## 5. Entity-Relationship Diagram (`erDiagram`)

**When to use**: Database design, data modeling, schema visualization, system relationships.

```mermaid
erDiagram
    CUSTOMER ||--o{ ORDER : "places"
    ORDER ||--|{ LINE_ITEM : "contains"
    PRODUCT ||--o{ LINE_ITEM : "ordered in"
    
    CUSTOMER {
        int id PK
        string name
        string email UK
        date created_at
    }
    ORDER {
        int id PK
        date order_date
        string status
        int customer_id FK
    }
    LINE_ITEM {
        int id PK
        int quantity
        decimal unit_price
        int order_id FK
        int product_id FK
    }
    PRODUCT {
        int id PK
        string name
        decimal price
        string category
    }
```

**Cardinality markers**:
- `||` — Exactly one
- `|o` — Zero or one
- `|{` — One or more
- `o{` — Zero or more
- `o|o` — Zero or one (both sides)

**Key annotations**: `PK` (primary key), `FK` (foreign key), `UK` (unique key)

---

## 6. Gantt Chart (`gantt`)

**When to use**: Project timelines, sprint planning, milestone tracking, phased delivery schedules.

```mermaid
gantt
    title Project Timeline
    dateFormat YYYY-MM-DD
    axisFormat %b %d
    
    section Planning
        Requirements Gathering :a1, 2024-01-01, 10d
        System Design :a2, after a1, 7d
    
    section Development
        Frontend Development :b1, after a2, 20d
        Backend Development :b2, after a2, 25d
        API Integration :b3, after b1, 10d
    
    section Testing
        Integration Testing :c1, after b3, 7d
        User Acceptance Testing :c2, after c1, 5d
    
    section Deployment
        Production Release :milestone, after c2, 0d
```

**Key syntax**:
- `dateFormat` — Input date format
- `axisFormat` — Display format for axis
- `section` — Groups tasks
- `:id, start, duration` — Task definition
- `:milestone` — Milestone marker
- `after id` — Dependency
- `crit` — Critical path
- `active` — Active task
- `done` — Completed task

---

## 7. Pie Chart (`pie`)

**When to use**: Proportional data, market share, distribution analysis, budget breakdowns.

```mermaid
pie title Market Share 2024
    "Product A" : 35
    "Product B" : 25
    "Product C" : 20
    "Others" : 20
```

---

## 8. Mindmap (`mindmap`)

**When to use**: Brainstorming, topic hierarchies, concept mapping, organizational structures, knowledge trees.

```mermaid
mindmap
  root((Microservices))
    Architecture
      API Gateway
      Service Registry
      Config Server
    Patterns
      CQRS
      Event Sourcing
      Saga
    Deployment
      Docker
      Kubernetes
      CI/CD
```

---

## 9. Quadrant Chart (`quadrantChart`)

**When to use**: Priority matrices, risk assessment, impact-effort analysis, strategic positioning.

```mermaid
quadrantChart
    title Priority Matrix
    x-axis Low Impact --> High Impact
    y-axis Low Effort --> High Effort
    quadrant-1 Do First
    quadrant-2 Schedule
    quadrant-3 Delegate
    quadrant-4 Eliminate
    Feature A: [0.8, 0.3]
    Feature B: [0.3, 0.7]
    Feature C: [0.9, 0.9]
    Feature D: [0.2, 0.2]
```

---

## 10. Requirement Diagram (`requirementDiagram`)

**When to use**: Requirements traceability, compliance mapping, specification linking.

```mermaid
requirementDiagram
    requirement test_req {
        id: TEST_001
        text: The system shall test
        risk: high
        verifymethod: test
    }
    element test_entity {
        type: simulation
    }
    test_entity - satisfies -> test_req
```

---

## 11. Gitgraph (`gitGraph`)

**When to use**: Git workflow visualization, branching strategy, release process illustration.

```mermaid
gitGraph
    commit id: "init"
    commit id: "feat: setup"
    branch develop
    checkout develop
    commit id: "feat: module-a"
    branch feature/auth
    checkout feature/auth
    commit id: "feat: login"
    commit id: "feat: register"
    checkout develop
    merge feature/auth id: "merge: auth"
    checkout main
    merge develop id: "release: v1.0"
```

---

## 12. Journey (`journey`)

**When to use**: User experience flows, customer journeys, service blueprints.

```mermaid
journey
    title Customer Purchase Journey
    section Discovery
        Visit website: 5: Customer
        Browse products: 4: Customer
        Read reviews: 3: Customer
    section Purchase
        Add to cart: 5: Customer
        Enter payment: 4: Customer
        Confirm order: 5: Customer
    section Post-purchase
        Receive confirmation: 5: System
        Track shipment: 4: Customer
        Receive product: 5: Customer
```

**Score**: 1-5 (1=terrible, 5=excellent experience)

---

## 13. C4 Architecture Diagrams

**When to use**: Software architecture at different zoom levels (context, containers, components, code).

### C4 Context
```mermaid
C4Context
    title System Context Diagram
    Person(user, "User", "A registered user")
    System(system, "Web Application", "Main application")
    System_Ext(email, "Email System", "Sends notifications")
    
    Rel(user, system, "Uses")
    Rel(system, email, "Sends emails")
```

### C4 Container
```mermaid
C4Container
    title Container Diagram
    Person(user, "User")
    System_Boundary(app, "Web Application") {
        Container(frontend, "Frontend", "React", "SPA")
        Container(api, "API Server", "Node.js", "REST API")
        ContainerDb(db, "Database", "PostgreSQL", "Data store")
    }
    Rel(user, frontend, "Uses")
    Rel(frontend, api, "API calls")
    Rel(api, db, "Reads/Writes")
```

---

## 14. Sankey (`sankey`)

**When to use**: Flow of resources, energy, money, or any quantity between nodes. Shows magnitude of flow.

*(Available in Mermaid 11+)*

---

## 15. Timeline (`timeline`)

**When to use**: Historical events, project milestones, chronological narratives.

```mermaid
timeline
    title Project History
    2024-Q1 : Kickoff : Team formation
    2024-Q2 : MVP : Alpha release
    2024-Q3 : Beta : User testing
    2024-Q4 : Launch : Production
```

---

## Choosing the Right Diagram Type

When multiple types could work, prefer:
1. **Flowchart** for anything procedural or decision-based (most versatile)
2. **Sequence diagram** when time-ordering and message-passing matters
3. **Class/ER diagram** when structure and relationships matter more than flow
4. **State diagram** when entities have discrete states and transitions
5. **Mindmap** when the structure is hierarchical and there's no "flow"

When in doubt, **offer the user a choice** between 2-3 appropriate types with a brief explanation of what each would highlight.