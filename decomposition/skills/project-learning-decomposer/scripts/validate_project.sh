#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <project-workspace> [--structure-only]" >&2
  exit 2
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage

project_root=$1
mode=${2:-"--full"}

case "$mode" in
  --structure-only|--full) ;;
  *) usage ;;
esac

[ -d "$project_root" ] || {
  echo "Project workspace does not exist: $project_root" >&2
  exit 1
}

missing=0

while IFS= read -r relative_path; do
  [ -n "$relative_path" ] || continue
  if [ ! -f "$project_root/$relative_path" ]; then
    echo "Missing required file: $relative_path" >&2
    missing=1
  fi
done <<'EOF'
project.yaml
EVIDENCE.md
GLOSSARY.md
ACCEPTANCE.md
detailed/00-learning-guide.md
detailed/01-project-and-product.md
detailed/02-product-journeys.md
detailed/03-environment-and-runbook.md
detailed/04-stack-and-dependencies.md
detailed/05-architecture.md
detailed/06-codebase-map.md
detailed/07-domain-and-data.md
detailed/09-key-code-deep-dives.md
detailed/10-interfaces-and-integrations.md
detailed/11-testing-and-debugging.md
detailed/12-quality-risks-and-tradeoffs.md
detailed/13-learning-exercises.md
detailed/14-interview-guide.md
EOF

core_flow_count=$(find "$project_root/detailed" -maxdepth 1 -type f -name '08-core-flow-*.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$core_flow_count" -lt 1 ]; then
  echo "Missing required core-flow document: detailed/08-core-flow-<name>.md" >&2
  missing=1
fi

[ "$missing" -eq 0 ] || exit 1

if [ "$mode" = "--structure-only" ]; then
  echo "Project workspace structure is valid: $project_root"
  exit 0
fi

failed=0

if rg -n '\{\{[A-Z0-9_]+\}\}' "$project_root"; then
  echo "Unresolved template placeholders found" >&2
  failed=1
fi

if rg -n 'TODO|TBD' "$project_root"; then
  echo "Unresolved TODO or TBD markers found" >&2
  failed=1
fi

if rg -n '\| G[0-6] .+\| 未开始 \|' "$project_root/ACCEPTANCE.md"; then
  echo "Acceptance stages remain incomplete" >&2
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Mechanical project validation passed: $project_root"
echo "Manual evidence and content review is still required before G6 acceptance."
