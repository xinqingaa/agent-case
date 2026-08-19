#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <project-id> <project-name> <source-path> [output-root]" >&2
  exit 2
}

[ "$#" -ge 3 ] && [ "$#" -le 4 ] || usage

project_id=$1
project_name=$2
source_path=$3

case "$project_id" in
  *[!a-z0-9-]*|''|-*|*-|*--*)
    echo "project-id must use lowercase letters, digits, and single interior hyphens" >&2
    exit 2
    ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
template_root="$repo_root/templates/project-decomposition"
output_root=${4:-"$repo_root/workspaces"}
project_root="$output_root/$project_id"
stage_root="$output_root/.${project_id}.init.$$"

[ -d "$template_root" ] || {
  echo "Template directory does not exist: $template_root" >&2
  exit 1
}

if [ -e "$project_root" ]; then
  echo "Refusing to overwrite existing project workspace: $project_root" >&2
  exit 1
fi

mkdir -p "$output_root"

cleanup() {
  if [ -d "$stage_root" ]; then
    rm -rf -- "$stage_root"
  fi
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$stage_root/detailed" "$stage_root/working"

escape_sed() {
  printf '%s' "$1" | sed 's/[\\&|]/\\&/g'
}

escaped_id=$(escape_sed "$project_id")
escaped_name=$(escape_sed "$project_name")
escaped_source=$(escape_sed "$source_path")

render() {
  source_file=$1
  target_file=$2
  sed \
    -e "s|{{PROJECT_ID}}|$escaped_id|g" \
    -e "s|{{PROJECT_NAME}}|$escaped_name|g" \
    -e "s|{{SOURCE_PATH}}|$escaped_source|g" \
    "$source_file" > "$target_file"
}

render "$template_root/project.yaml" "$stage_root/project.yaml"
render "$template_root/EVIDENCE.md" "$stage_root/EVIDENCE.md"
render "$template_root/GLOSSARY.md" "$stage_root/GLOSSARY.md"
render "$template_root/ACCEPTANCE.md" "$stage_root/ACCEPTANCE.md"
render "$template_root/00-learning-guide.md" "$stage_root/detailed/00-learning-guide.md"
render "$template_root/01-project-and-product.md" "$stage_root/detailed/01-project-and-product.md"
render "$template_root/02-product-journeys.md" "$stage_root/detailed/02-product-journeys.md"
render "$template_root/03-environment-and-runbook.md" "$stage_root/detailed/03-environment-and-runbook.md"
render "$template_root/04-stack-and-dependencies.md" "$stage_root/detailed/04-stack-and-dependencies.md"
render "$template_root/05-architecture.md" "$stage_root/detailed/05-architecture.md"
render "$template_root/06-codebase-map.md" "$stage_root/detailed/06-codebase-map.md"
render "$template_root/07-domain-and-data.md" "$stage_root/detailed/07-domain-and-data.md"
render "$template_root/08-core-flow.md" "$stage_root/detailed/08-core-flow-main.md"
render "$template_root/09-key-code-deep-dives.md" "$stage_root/detailed/09-key-code-deep-dives.md"
render "$template_root/10-interfaces-and-integrations.md" "$stage_root/detailed/10-interfaces-and-integrations.md"
render "$template_root/11-testing-and-debugging.md" "$stage_root/detailed/11-testing-and-debugging.md"
render "$template_root/12-quality-risks-and-tradeoffs.md" "$stage_root/detailed/12-quality-risks-and-tradeoffs.md"
render "$template_root/13-learning-exercises.md" "$stage_root/detailed/13-learning-exercises.md"
render "$template_root/14-interview-guide.md" "$stage_root/detailed/14-interview-guide.md"

mv "$stage_root" "$project_root"
trap - EXIT HUP INT TERM

echo "Created project decomposition workspace: $project_root"
echo "Source project was not inspected. Complete project.yaml authorization before analysis."
