#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

if ARGV.length != 1
  warn "Usage: #{$PROGRAM_NAME} <skill-directory>"
  exit 2
end

skill_dir = File.expand_path(ARGV.first)
skill_file = File.join(skill_dir, "SKILL.md")
metadata_file = File.join(skill_dir, "agents", "openai.yaml")
errors = []

unless File.file?(skill_file)
  warn "Missing SKILL.md: #{skill_file}"
  exit 1
end

content = File.read(skill_file)
frontmatter = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)

if frontmatter.nil?
  errors << "SKILL.md is missing YAML frontmatter"
else
  begin
    metadata = YAML.safe_load(frontmatter[1], permitted_classes: [], aliases: false)
    expected_name = File.basename(skill_dir)
    errors << "skill name must match folder name #{expected_name}" unless metadata["name"] == expected_name
    errors << "skill description must be non-empty" unless metadata["description"].is_a?(String) && !metadata["description"].strip.empty?
  rescue StandardError => e
    errors << "SKILL.md frontmatter is invalid: #{e.message}"
  end
end

errors << "SKILL.md contains unresolved placeholders" if content.match?(/\{\{[A-Z0-9_]+\}\}/)

if File.file?(metadata_file)
  begin
    metadata = YAML.safe_load(File.read(metadata_file), permitted_classes: [], aliases: false)
    errors << "agents/openai.yaml must define interface.display_name" unless metadata.dig("interface", "display_name").is_a?(String)
  rescue StandardError => e
    errors << "agents/openai.yaml is invalid: #{e.message}"
  end
end

if errors.empty?
  puts "Skill structure is valid: #{skill_dir}"
  exit 0
end

errors.each { |error| warn error }
exit 1
