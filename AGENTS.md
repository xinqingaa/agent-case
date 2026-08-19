# Repository Instructions

## Repository purpose

This repository builds an evidence-backed learning-documentation system for existing codebases. The active specifications live under `docs/specifications/`.

## Default authorization

- Treat every project as L0 until its `workspaces/<project-id>/project.yaml` records a narrower, explicit authorization.
- Do not inspect files under `sources/` merely because a task mentions a project. Scope and permission must be recorded first.
- Reading source does not imply permission to install dependencies, execute commands, use the network, read data, contact external services, or modify source.
- Keep `sources/` read-only unless the user explicitly authorizes a separate source-change task.
- Never read real secrets, runtime databases, personal data, generated output, dependency directories, or cache directories as part of ordinary decomposition.

## Where work belongs

- Current project documentation: `docs/`
- Repository Skill: `.agents/skills/project-learning-decomposer/`
- Templates: `templates/project-decomposition/`
- Deterministic tooling: `scripts/`
- Decomposition outputs: `workspaces/<project-id>/`
- Historical material: `archive/`; do not cite it as current implementation truth.

Do not recreate a `decomposition/`, `code/`, or root-level legacy `assets/` directory.

## Documentation rules

- Detailed project documents are the source of truth; summaries are derived artifacts.
- Start from product journeys, then map to architecture, data, core flows, and key code.
- Mark claims as `[R]`, `[V]`, `[C]`, `[I]`, or `[U]` and cite stable evidence IDs.
- Existing READMEs, names, archived documents, comments, and interview notes are candidate evidence, not implementation facts.
- Keep unknowns and contradictions visible. Do not convert an unverified command into runtime evidence.

## Change and verification rules

- Preserve unrelated user changes and use non-destructive migrations.
- Update active path references when moving specifications, templates, scripts, or workspaces.
- After changing templates or scripts, run `./tests/test-scripts.sh`.
- After changing active documentation or repository layout, run `./scripts/check-repository.sh`.
- Before claiming a project workspace complete, run `./scripts/validate-project.sh <workspace>` and perform the manual acceptance review.
