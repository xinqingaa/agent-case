---
name: project-learning-decomposer
description: Build evidence-backed, beginner-oriented learning documentation for a complete local codebase, including product journeys, runnable setup, architecture, core execution flows, key-code reading paths, exercises, and interview review. Use when the user asks to understand, decompose, teach, document, or onboard into an existing project. Do not use for narrow code explanations, feature implementation, or ordinary README edits.
---

# Project Learning Decomposer

Turn a complete project into a verified learning system. Treat the detailed document set as the source of truth; produce a short version only after the detailed set passes acceptance.

## Before analyzing source

1. Find the repository's decomposition specification. In this repository, read `decomposition/SPEC.md` completely.
2. Read or create the target project's `project.yaml`.
3. Check the recorded authorization level. Do not inspect or run anything beyond it.
4. Keep analysis output outside the source project unless the user explicitly requests otherwise.
5. Preserve existing project files and unrelated user changes.

Authorization is cumulative only where the specification says so. Permission to read source does not imply permission to install dependencies, run services, write databases, contact external systems, or modify the project.

## Choose the current phase

- For framework or template work at L0, do not inspect source. Work only on the specification, templates, skill, and acceptance rules.
- For a new project, read [references/workflow.md](references/workflow.md) and begin at G0.
- For evidence capture or claim review, read [references/evidence-and-quality.md](references/evidence-and-quality.md).
- For an existing partial document set, inventory it first, map it to the required contract, and retain valid material. Do not rewrite merely for stylistic uniformity.

At the start of each phase, state what the authorization permits and what evidence the phase must produce. Stop at the next authorization boundary rather than treating a broad project goal as blanket permission.

## Required behavior

- Start from users and product journeys, then map those journeys to architecture and code.
- Read selectively. Use manifests, entry points, symbol search, call sites, tests, and runtime observations to narrow the investigation.
- Record evidence while investigating instead of reconstructing citations after drafting.
- Mark claims as runtime-verified, statically verified, user-confirmed, inferred, or unknown.
- Verify setup commands when L4 is granted. A command copied from documentation is not runtime evidence.
- Trace representative flows end to end, including validation, data changes, external calls, output, failures, and tests.
- Explain key code by responsibility, callers, callees, state, side effects, invariants, and change impact. Avoid file-by-file narration.
- Keep interview claims within verified project facts and user-confirmed personal contributions.
- Run the acceptance gate before declaring the detailed version complete.

## Outputs

Use the document contract in `decomposition/SPEC.md` and the templates in `decomposition/templates/`. Create one workspace under `decomposition/projects/<project-id>/` containing:

- `project.yaml`, `EVIDENCE.md`, `GLOSSARY.md`, and `ACCEPTANCE.md`.
- The required detailed documents under `detailed/`.
- Temporary notes under `working/`; do not cite working notes as final evidence.

Initialize a workspace with `scripts/init_project.sh <project-id> <project-name> <source-path>` when the repository layout matches this skill. The script must not inspect the source path.

After initialization, run `scripts/validate_project.sh <project-workspace> --structure-only`. Before G6, run the same script without `--structure-only`; treat it as a mechanical precheck, not a substitute for evidence review.

## Completion

Do not claim completion when a blocking acceptance item remains. Report what is verified, what is inferred, what could not be run, and what authorization or information is needed next.
