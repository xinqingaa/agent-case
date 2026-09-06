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

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
schema_path="$repo_root/schemas/project.schema.json"

[ -d "$project_root" ] || {
  echo "Project workspace does not exist: $project_root" >&2
  exit 1
}

missing=0

required_files='project.yaml
EVIDENCE.md
GLOSSARY.md
ACCEPTANCE.md
foundation-project.md
foundation-journeys.md
foundation-architecture.md
foundation-core-flow-main.md
source-study-guide.md'
core_flow_dir="$project_root"
core_flow_pattern='foundation-core-flow-*.md'

# The learning profile controls optional learning tracks. Excluded tracks are
# deliberately not required; required tracks must have at least one document.
profile_values=$(ruby -ryaml -e 'd=YAML.safe_load(File.read(ARGV[0]), permitted_classes: [], aliases: false) || {}; p=d["learning_profile"] || {}; puts [p["source_study"],p["minimal_replication"],p["extension_development"]].join(" ")' "$project_root/project.yaml")
set -- $profile_values
source_study=${1:-required}
replication=${2:-excluded}
extension=${3:-excluded}

case "$source_study" in required) required_files="$required_files
source-study-exercises.md";; esac
case "$replication" in required) required_files="$required_files
replication-minimal.md";; esac
case "$extension" in required) required_files="$required_files
extension-add-tool.md";; esac

printf '%s\n' "$required_files" | while IFS= read -r relative_path; do
  [ -n "$relative_path" ] || continue
  if [ ! -f "$project_root/$relative_path" ]; then
    echo "Missing required file: $relative_path" >&2
    missing=1
  fi
done

core_flow_count=$(find "$core_flow_dir" -maxdepth 1 -type f -name "$core_flow_pattern" 2>/dev/null | wc -l | tr -d ' ')
if [ "$core_flow_count" -lt 1 ]; then
  echo "Missing required core-flow document: foundation-core-flow-<name>.md" >&2
  missing=1
fi

[ "$missing" -eq 0 ] || exit 1

ruby "$script_dir/validate-project-yaml.rb" "$schema_path" "$project_root/project.yaml"

if [ "$mode" = "--structure-only" ]; then
  echo "Project workspace structure is valid: $project_root"
  exit 0
fi

failed=0

if rg -n '\{\{[A-Z0-9_]+\}\}' "$project_root"; then
  echo "Unresolved template placeholders found" >&2
  failed=1
fi

if rg -n '\bTODO\b|\bTBD\b' "$project_root"; then
  echo "Unresolved TODO or TBD markers found" >&2
  failed=1
fi

if rg -n '^\| P[0-6] .+\| 未开始 \|' "$project_root/ACCEPTANCE.md"; then
  echo "Acceptance stages remain incomplete" >&2
  failed=1
fi

if ! rg -q '^\| P6 .+\| (已完成|通过|有条件通过) \|' "$project_root/ACCEPTANCE.md"; then
  echo "G6 must be marked 已完成, 通过, or 有条件通过" >&2
  failed=1
fi

project_status=$(ruby -ryaml -e 'data = YAML.safe_load(File.read(ARGV[0]), permitted_classes: [], aliases: false); puts data.dig("project", "status")' "$project_root/project.yaml")
if [ "$project_status" != "accepted" ]; then
  echo "project.status must be accepted before full validation can pass" >&2
  failed=1
fi

temp_dir=$(mktemp -d)
cleanup() {
  rm -rf -- "$temp_dir"
}
trap cleanup EXIT HUP INT TERM

rg --no-filename '^\| E-[A-Z]+-[0-9]+' "$project_root/EVIDENCE.md" \
  | rg -o 'E-[A-Z]+-[0-9]+' | sort -u > "$temp_dir/defined"

rg --no-filename -o 'E-[A-Z]+-[0-9]+' \
  "$project_root" "$project_root/GLOSSARY.md" "$project_root/ACCEPTANCE.md" \
  | sort -u > "$temp_dir/referenced"

comm -23 "$temp_dir/referenced" "$temp_dir/defined" > "$temp_dir/missing-evidence"
if [ -s "$temp_dir/missing-evidence" ]; then
  echo "Referenced evidence IDs are not defined:" >&2
  sed 's/^/  /' "$temp_dir/missing-evidence" >&2
  failed=1
fi

if rg -q '^\| E-[A-Z]+-[0-9]+.*\[R\]' "$project_root/EVIDENCE.md" \
  && ! rg -q '^### RUN-[0-9]+' "$project_root/EVIDENCE.md"; then
  echo "Runtime evidence exists without a RUN record" >&2
  failed=1
fi

fence_count=$(rg -o '^```' "$project_root" | wc -l | tr -d ' ')
if [ $((fence_count % 2)) -ne 0 ]; then
  echo "Markdown code fences are unbalanced" >&2
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Mechanical project validation passed: $project_root"
echo "Manual evidence, authorization, factual, and learning review is still required before G6 acceptance."
