# Evidence and quality rules

Use this reference while capturing evidence, reviewing claims, or running final acceptance.

## Evidence strength

Prefer evidence in this order for implementation behavior:

1. Reproducible runtime observation.
2. Executed tests with observable assertions.
3. Current source and configuration.
4. Version history explaining a change.
5. Existing project documentation.
6. User-confirmed intent or history.
7. Inference from names, patterns, or incomplete artifacts.

Higher-ranked evidence does not automatically invalidate product intent. When intent and implementation differ, document both as an explicit divergence.

## Evidence IDs

Use stable categories:

- `E-BOOT-*`: environment, build, startup, and health.
- `E-PROD-*`: users, scenarios, and product behavior.
- `E-ARCH-*`: system boundaries and dependencies.
- `E-FLOW-*`: end-to-end execution flows.
- `E-DATA-*`: schemas, state, persistence, and transactions.
- `E-TEST-*`: tests and quality checks.
- `E-RISK-*`: security, performance, defects, and debt.
- `E-USER-*`: user-confirmed intent or contribution.
- `E-OPEN-*`: unresolved questions and proposed verification.

Do not renumber evidence casually after documents cite it.

## Claim handling

- `[R]` requires a recorded command or interaction and an observed result.
- `[V]` requires a precise source, config, test, or history location.
- `[C]` records what the user confirmed; it does not prove runtime behavior.
- `[I]` states the inference and the evidence that makes it plausible.
- `[U]` states what is missing and how it could be verified.

Metrics need the metric definition, dataset or workload, measurement method, environment, result, and date. Without these, present a number only as a user-provided claim or remove it.

## Citation precision

Prefer a symbol, config key, test name, or narrow line reference. A repository root or large file is not precise evidence. Command evidence should include enough output to identify success or failure without pasting sensitive or noisy logs.

## Cross-document consistency

Before acceptance, compare:

- Product steps against core-flow triggers and outcomes.
- Architecture nodes against module paths and runtime processes.
- Setup commands against the verified environment and actual ports.
- Data-model descriptions against flow state changes.
- Interview claims against evidence and user-confirmed contributions.
- Exercises against available commands and success signals.

When two sources conflict, do not silently choose one. Record the conflict, the stronger evidence, and the remaining uncertainty.

