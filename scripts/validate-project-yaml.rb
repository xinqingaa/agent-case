#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

if ARGV.length != 2
  warn "Usage: #{$PROGRAM_NAME} <schema.json> <project.yaml>"
  exit 2
end

schema_path, yaml_path = ARGV

begin
  schema = JSON.parse(File.read(schema_path))
  data = YAML.safe_load(File.read(yaml_path), permitted_classes: [], aliases: false)
rescue StandardError => e
  warn "Metadata parse failed: #{e.message}"
  exit 1
end

errors = []

def validate(schema, value, path, errors)
  if schema.key?("const") && value != schema["const"]
    errors << "#{path}: must equal #{schema['const'].inspect}"
  end

  if schema["enum"] && !schema["enum"].include?(value)
    errors << "#{path}: must be one of #{schema['enum'].join(', ')}"
  end

  case schema["type"]
  when "object"
    unless value.is_a?(Hash)
      errors << "#{path}: must be an object"
      return
    end
    Array(schema["required"]).each do |key|
      errors << "#{path}.#{key}: is required" unless value.key?(key)
    end
    schema.fetch("properties", {}).each do |key, child_schema|
      validate(child_schema, value[key], "#{path}.#{key}", errors) if value.key?(key)
    end
  when "array"
    unless value.is_a?(Array)
      errors << "#{path}: must be an array"
      return
    end
    min_items = schema["minItems"]
    errors << "#{path}: must contain at least #{min_items} item(s)" if min_items && value.length < min_items
    value.each_with_index { |item, index| validate(schema["items"], item, "#{path}[#{index}]", errors) } if schema["items"]
  when "string"
    unless value.is_a?(String)
      errors << "#{path}: must be a string"
      return
    end
    min_length = schema["minLength"]
    errors << "#{path}: must not be empty" if min_length && value.length < min_length
    pattern = schema["pattern"]
    errors << "#{path}: does not match #{pattern}" if pattern && !Regexp.new(pattern).match?(value)
  when "boolean"
    errors << "#{path}: must be true or false" unless value == true || value == false
  end
end

validate(schema, data, "$", errors)

if errors.empty?
  puts "Project metadata is valid: #{yaml_path}"
  exit 0
end

errors.each { |error| warn error }
exit 1
