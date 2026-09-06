---
name: project-learning-decomposer
description: Build evidence-backed learning documentation for a complete codebase. Use for full-project decomposition, onboarding, architecture-to-collaboration tracing, or business-capability writeups. Omit generic frontend tutorials and function deep-dives. Do not use for narrow code explanations, feature implementation, or ordinary README edits.
---

# Project Learning Decomposer

Turn a complete project into a verified learning system. Treat the detailed document set as the source of truth; produce a short version only after the detailed set passes acceptance. Stage codes, evidence IDs, and the capability matrix are agent-side constraints. Talk to the user in plain language.

## Before analyzing source

1. Read the active specifications under `docs/specifications/`, starting with `authorization.md` and `decomposition-workflow.md`.
2. Read or create the target project's `project.yaml`.
3. Check both the recorded authorization level and every capability field. Missing or false capabilities are denied.
4. Keep all analysis output under `workspaces/<project-id>/`, outside the source project.
5. Preserve existing project files and unrelated user changes.

The level is a human summary, not an executable permission grant. Permission to read source does not imply permission to inspect Git history, execute commands, install dependencies, run services, use the network, read data, contact external systems, or modify source.

Ask the user only whether source may be read, whether the project may be run locally, and whether the network may be used. Translate those answers into `project.yaml`. Do not require the user to learn stage codes or evidence IDs.

## Choose the current phase

- For framework or template work at L0, do not inspect source. Work only on `docs/`, `.agents/`, `.cursor/`, `.claude/`, `templates/`, `schemas/`, `scripts/`, `tests/`, and empty `workspaces/` drills.
- For a new project, read [references/workflow.md](references/workflow.md) and begin at P1 after the upstream P0 contract is frozen.
- For evidence capture or claim review, read [references/evidence-and-quality.md](references/evidence-and-quality.md).
- For an existing partial document set, inventory it first, map it to the required contract, and retain valid material. Do not rewrite merely for stylistic uniformity.

At the start of each phase, state in plain language what the authorization permits and what the phase must produce. Stop at the next authorization boundary rather than treating a broad project goal as blanket permission.

## Required behavior

- Start from users and product journeys, then map those journeys to architecture, collaboration, and business thinking.
- Follow the default learner profile in `docs/specifications/document-contract.md`: project-unfamiliar, not programming-beginner; omit pure frontend implementation tutorials; explain backend and AI concepts only when this project uses them; go deeper only when asked.
- Read source as verification material. Do not turn learning docs into function deep-dives or caller/callee tours.
- Read selectively. Use manifests, entry points, symbol search, call sites, tests, and runtime observations to narrow the investigation.
- Record evidence in `EVIDENCE.md` while investigating instead of reconstructing citations after drafting.
- Mark claims in the evidence ledger as runtime-verified, statically verified, user-confirmed, inferred, or unknown. In the applicable flat `foundation-*` and learning-track files, write the same facts in plain language and locate them with paths, modules, or commands.
- Verify setup commands only when the exact execution capabilities are true. A command copied from documentation is not runtime evidence.
- Trace representative flows end to end, including validation, data changes, external calls, output, failures, and tests.
- Keep interview claims within verified project facts and user-confirmed personal contributions.
- Run the acceptance gate before declaring the detailed version complete.

## Outputs

Use `docs/specifications/document-contract.md` and `templates/project-decomposition/`. Create one completely flat workspace under `workspaces/<project-id>/` containing:

- `project.yaml`, `EVIDENCE.md`, `GLOSSARY.md`, and `ACCEPTANCE.md`.
- The applicable `foundation-*`, `source-study-*`, `replication-*`, and `extension-*` documents at the workspace root.
- Temporary notes as `working-*.md`; do not cite working notes as final evidence.

Read `learning_profile` before drafting. It determines which learning tracks are required, optional, or excluded. Do not generate or validate excluded tracks.

Initialize a workspace with `scripts/init-project.sh <project-id> <project-name> <source-path>`. The script must not inspect the source path.

After initialization, run `scripts/validate-project.sh <project-workspace> --structure-only`. Before P6, run the same script without `--structure-only`; treat it as a mechanical precheck, not a substitute for evidence review.

## Completion

Do not claim completion when a blocking acceptance item remains. Report what is verified, what is inferred, what could not be run, and what authorization or information is needed next.
