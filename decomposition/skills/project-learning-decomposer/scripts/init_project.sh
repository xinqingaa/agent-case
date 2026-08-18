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
  *[!a-z0-9-]*|'')
    echo "project-id must contain only lowercase letters, digits, and hyphens" >&2
    exit 2
    ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
decomposition_root=$(CDPATH= cd -- "$script_dir/../../.." && pwd)
template_root="$decomposition_root/templates"
output_root=${4:-"$decomposition_root/projects"}
project_root="$output_root/$project_id"

if [ -e "$project_root" ]; then
  echo "Refusing to overwrite existing project workspace: $project_root" >&2
  exit 1
fi

mkdir -p "$project_root/detailed" "$project_root/working"

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

render "$template_root/project.yaml" "$project_root/project.yaml"
render "$template_root/EVIDENCE.md" "$project_root/EVIDENCE.md"
render "$template_root/GLOSSARY.md" "$project_root/GLOSSARY.md"
render "$template_root/ACCEPTANCE.md" "$project_root/ACCEPTANCE.md"
render "$template_root/00-learning-guide.md" "$project_root/detailed/00-learning-guide.md"
render "$template_root/01-project-and-product.md" "$project_root/detailed/01-project-and-product.md"
render "$template_root/02-product-journeys.md" "$project_root/detailed/02-product-journeys.md"
render "$template_root/03-environment-and-runbook.md" "$project_root/detailed/03-environment-and-runbook.md"
render "$template_root/04-stack-and-dependencies.md" "$project_root/detailed/04-stack-and-dependencies.md"
render "$template_root/05-architecture.md" "$project_root/detailed/05-architecture.md"
render "$template_root/06-codebase-map.md" "$project_root/detailed/06-codebase-map.md"
render "$template_root/07-domain-and-data.md" "$project_root/detailed/07-domain-and-data.md"
render "$template_root/08-core-flow.md" "$project_root/detailed/08-core-flow-main.md"
render "$template_root/09-key-code-deep-dives.md" "$project_root/detailed/09-key-code-deep-dives.md"
render "$template_root/10-interfaces-and-integrations.md" "$project_root/detailed/10-interfaces-and-integrations.md"
render "$template_root/11-testing-and-debugging.md" "$project_root/detailed/11-testing-and-debugging.md"
render "$template_root/12-quality-risks-and-tradeoffs.md" "$project_root/detailed/12-quality-risks-and-tradeoffs.md"
render "$template_root/13-learning-exercises.md" "$project_root/detailed/13-learning-exercises.md"
render "$template_root/14-interview-guide.md" "$project_root/detailed/14-interview-guide.md"

echo "Created project decomposition workspace: $project_root"
echo "Source project was not inspected. Record authorization in project.yaml before analysis."
