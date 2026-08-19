#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
cd "$repo_root"

failed=0

while IFS= read -r required_path; do
  [ -e "$required_path" ] || {
    echo "Missing required repository path: $required_path" >&2
    failed=1
  }
done <<'EOF'
README.md
AGENTS.md
CONTRIBUTING.md
docs/README.md
docs/specifications/decomposition-workflow.md
docs/specifications/authorization.md
docs/specifications/evidence-model.md
docs/specifications/document-contract.md
docs/specifications/acceptance.md
.agents/skills/project-learning-decomposer/SKILL.md
templates/project-decomposition/project.yaml
schemas/project.schema.json
scripts/init-project.sh
scripts/validate-project.sh
sources/README.md
workspaces/README.md
archive/README.md
EOF

for obsolete_dir in decomposition code assets; do
  if [ -e "$obsolete_dir" ]; then
    echo "Obsolete root path still exists: $obsolete_dir" >&2
    failed=1
  fi
done

active_files=$(find docs .agents/skills templates workspaces -type f \
  \( -name '*.md' -o -name '*.yaml' -o -name '*.sh' \) \
  ! -path 'docs/guides/migration-from-v0.md' -print)
if rg -n \
  'decomposition/(SPEC|PLAN|templates|skills|projects)|scripts/(init_project|validate_project)|code/(cloud_agent|deep_research|imooc-mas)' \
  README.md AGENTS.md CONTRIBUTING.md $active_files; then
  echo "Active files contain obsolete executable paths" >&2
  failed=1
fi

sh -n scripts/init-project.sh scripts/validate-project.sh scripts/check-repository.sh
ruby -c scripts/validate-project-yaml.rb >/dev/null
ruby -c scripts/check-links.rb >/dev/null
ruby -c scripts/validate-skill.rb >/dev/null
ruby scripts/validate-skill.rb .agents/skills/project-learning-decomposer || failed=1

markdown_files=$(find docs .agents/skills templates workspaces scripts schemas tests archive -type f -name '*.md' -print)
ruby scripts/check-links.rb README.md CONTRIBUTING.md sources/README.md $markdown_files || failed=1

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Repository structure and active documentation checks passed"
