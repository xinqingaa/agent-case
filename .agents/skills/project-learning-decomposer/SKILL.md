---
name: project-learning-decomposer
description: Build evidence-backed, beginner-oriented learning documentation for a complete codebase. Use for full-project decomposition, onboarding, learning guides, architecture-to-code tracing, or improving an existing decomposition workspace. Do not use for narrow code explanations, feature implementation, or ordinary README edits.
---

# Project Learning Decomposer

Turn a complete project into a verified learning system. Treat the detailed document set as the source of truth; produce a short version only after the detailed set passes acceptance.

## Before analyzing source

1. Read the active specifications under `docs/specifications/`, starting with `authorization.md` and `decomposition-workflow.md`.
2. Read or create the target project's `project.yaml`.
3. Check both the recorded authorization level and every capability field. Missing or false capabilities are denied.
4. Keep all analysis output under `workspaces/<project-id>/`, outside the source project.
5. Preserve existing project files and unrelated user changes.

The level is a human summary, not an executable permission grant. Permission to read source does not imply permission to inspect Git history, execute commands, install dependencies, run services, use the network, read data, contact external systems, or modify source.

## Choose the current phase

- For framework or template work at L0, do not inspect source. Work only on `docs/`, `.agents/`, `templates/`, `schemas/`, `scripts/`, and `tests/`.
- For a new project, read [references/workflow.md](references/workflow.md) and begin at G0.
- For evidence capture or claim review, read [references/evidence-and-quality.md](references/evidence-and-quality.md).
- For an existing partial document set, inventory it first, map it to the required contract, and retain valid material. Do not rewrite merely for stylistic uniformity.

At the start of each phase, state what the authorization permits and what evidence the phase must produce. Stop at the next authorization boundary rather than treating a broad project goal as blanket permission.

## Required behavior

- Start from users and product journeys, then map those journeys to architecture and code.
- Read selectively. Use manifests, entry points, symbol search, call sites, tests, and runtime observations to narrow the investigation.
- Record evidence while investigating instead of reconstructing citations after drafting.
- Mark claims as runtime-verified, statically verified, user-confirmed, inferred, or unknown.
- Verify setup commands only when the exact execution capabilities are true. A command copied from documentation is not runtime evidence.
- Trace representative flows end to end, including validation, data changes, external calls, output, failures, and tests.
- Explain key code by responsibility, callers, callees, state, side effects, invariants, and change impact. Avoid file-by-file narration.
- Keep interview claims within verified project facts and user-confirmed personal contributions.
- Run the acceptance gate before declaring the detailed version complete.

## Outputs

Use `docs/specifications/document-contract.md` and `templates/project-decomposition/`. Create one workspace under `workspaces/<project-id>/` containing:

- `project.yaml`, `EVIDENCE.md`, `GLOSSARY.md`, and `ACCEPTANCE.md`.
- The required detailed documents under `detailed/`.
- Temporary notes under `working/`; do not cite working notes as final evidence.

Initialize a workspace with `scripts/init-project.sh <project-id> <project-name> <source-path>`. The script must not inspect the source path.

After initialization, run `scripts/validate-project.sh <project-workspace> --structure-only`. Before G6, run the same script without `--structure-only`; treat it as a mechanical precheck, not a substitute for evidence review.

## Completion

Do not claim completion when a blocking acceptance item remains. Report what is verified, what is inferred, what could not be run, and what authorization or information is needed next.
