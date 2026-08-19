#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
temp_root=$(mktemp -d)
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

cleanup() {
  rm -rf -- "$temp_root"
}
trap cleanup EXIT HUP INT TERM

expect_failure() {
  if "$@" >/dev/null 2>&1; then
    echo "Expected command to fail: $*" >&2
    exit 1
  fi
}

ruby "$repo_root/scripts/validate-project-yaml.rb" \
  "$repo_root/schemas/project.schema.json" \
  "$repo_root/tests/fixtures/valid-project.yaml"

expect_failure ruby "$repo_root/scripts/validate-project-yaml.rb" \
  "$repo_root/schemas/project.schema.json" \
  "$repo_root/tests/fixtures/invalid-permission.yaml"

"$repo_root/scripts/init-project.sh" fixture-project "Fixture Project" /not-inspected/source "$temp_root"
workspace="$temp_root/fixture-project"

"$repo_root/scripts/validate-project.sh" "$workspace" --structure-only
expect_failure "$repo_root/scripts/init-project.sh" fixture-project "Fixture Project" /not-inspected/source "$temp_root"
expect_failure "$repo_root/scripts/init-project.sh" Invalid_ID "Invalid" /not-inspected/source "$temp_root"
expect_failure "$repo_root/scripts/validate-project.sh" "$workspace" --full

cp -R "$workspace" "$temp_root/missing-flow"
rm "$temp_root/missing-flow/detailed/08-core-flow-main.md"
expect_failure "$repo_root/scripts/validate-project.sh" "$temp_root/missing-flow" --structure-only

cp -R "$workspace" "$temp_root/completed"
ruby -e '
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
  root = ARGV.fetch(0)
  filled = "\u5df2\u586b\u5199"
  incomplete = "| \u672a\u5f00\u59cb |"
  complete = "| \u5df2\u5b8c\u6210 |"
  Dir.glob(File.join(root, "**", "*"), File::FNM_DOTMATCH).each do |path|
    next unless File.file?(path)
    next unless [".md", ".yaml"].include?(File.extname(path))
    content = File.read(path).gsub(/\{\{[A-Z0-9_]+\}\}/, filled)
    content = content.gsub("status: \"draft\"", "status: \"accepted\"")
    content = content.gsub(incomplete, complete)
    File.write(path, content)
  end
' "$temp_root/completed"
"$repo_root/scripts/validate-project.sh" "$temp_root/completed" --full

cp -R "$temp_root/completed" "$temp_root/missing-evidence"
printf '\nBroken evidence reference: [V][E-ARCH-999]\n' >> "$temp_root/missing-evidence/detailed/05-architecture.md"
expect_failure "$repo_root/scripts/validate-project.sh" "$temp_root/missing-evidence" --full

cp -R "$temp_root/completed" "$temp_root/missing-run"
sed '/^### RUN-[0-9]/d' "$temp_root/missing-run/EVIDENCE.md" > "$temp_root/missing-run/EVIDENCE.tmp"
mv "$temp_root/missing-run/EVIDENCE.tmp" "$temp_root/missing-run/EVIDENCE.md"
expect_failure "$repo_root/scripts/validate-project.sh" "$temp_root/missing-run" --full

"$repo_root/scripts/check-repository.sh"
echo "All script tests passed"
