# Project decomposition workflow

Use this reference when starting or continuing a project decomposition.

## P0: Scope and authorization

1. Resolve the source path without reading its contents beyond the current authorization.
2. Record project ID, name, audience, source revision, authorization level, capability matrix, exclusions, and prohibited actions. Translate the user's plain-language permission (read source / run locally / use network) into `project.yaml`; do not ask them to fill stage codes.
3. Initialize the output workspace.
4. Define the questions the decomposition must answer and the likely product journeys without presenting guesses as facts.

Exit when `project.yaml` is complete enough to constrain the next phase.

## G1: Reconnaissance

When authorization permits, identify manifests, runtime constraints, entry points, configuration, tests, major directories, generated outputs, and external-service indicators. Prefer breadth first and selective depth second.

Create an initial map of:

- Product entry surfaces: UI, API, CLI, scheduled job, event consumer, or library API.
- Runtime components and process boundaries.
- Stable modules and their responsibilities.
- Data stores, queues, caches, model providers, and other integrations.
- Candidate core flows and the files needed to confirm them.

Record unknowns and contradictions, especially differences between existing documentation and implementation.

## G2: Runtime baseline

Only perform actions whose exact capability fields are true. Capture runtime versions before dependency installation. Separate local execution, dependency installation, service startup, network access, browser access, and data access rather than inferring them from a level.

For every command, record working directory, prerequisites, command, exit status, signal observed, side effects, and evidence ID. A process merely remaining alive is not always a success signal; prefer health endpoints, rendered UI state, logs, or a verified request.

## G3: Product and architecture

Describe actors, goals, inputs, outputs, and failure-visible behavior. Map product steps to actual system components. Build a system-context view before module and runtime views.

Do not label an architecture pattern unless direct evidence supports it. State observed boundaries and dependency directions when the label is uncertain.

## G4: Core flows

Select flows using these priorities:

1. Central product value.
2. Coverage of important architectural boundaries.
3. Meaningful business decisions or state changes.
4. Technically distinctive behavior.
5. Interview and learning value.

Trace each flow from trigger to visible outcome. Confirm call sites and data movement rather than assuming them from similarly named functions. Include failures, retries, fallbacks, authorization, state transitions, and relevant tests.

## G5: Topics and learning design

Analyze only applicable topics. Typical topics include configuration, authentication, persistence, transactions, state management, caching, queues, model calls, observability, tests, security, performance, and deployment.

Convert the verified system model into a learning sequence:

- Explain only the prerequisites this project actually needs.
- Give a module map and collaboration order, not a function reading list.
- Write business capabilities, decision rules, and frontend participation boundaries.
- Add location and debugging exercises before any modification exercises.
- State exact completion checks for exercises.
- Build interview material from verified facts, not aspirational claims.

## P6: Acceptance

Run every blocking check in `ACCEPTANCE.md`. Cross-check paths, symbols, commands, diagrams, and evidence references. Search for unsupported performance numbers, unmarked assumptions, leaked secrets, stale placeholders, and contradictions across documents.

The detailed set is complete only when blockers pass or the user explicitly records a narrow waiver with its consequences.
