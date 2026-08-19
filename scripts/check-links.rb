#!/usr/bin/env ruby
# frozen_string_literal: true

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

if ARGV.empty?
  warn "Usage: #{$PROGRAM_NAME} <markdown-file>..."
  exit 2
end

errors = []

ARGV.each do |file|
  next unless File.file?(file)

  File.readlines(file, chomp: true, encoding: "UTF-8").each_with_index do |line, index|
    line.scan(/!?(?:\[[^\]]*\])\(([^)]+)\)/).flatten.each do |raw_target|
      target = raw_target.strip
      target = target[1..-2] if target.start_with?("<") && target.end_with?(">")
      target = target.split(/\s+["']/).first
      next if target.empty? || target.start_with?("#")
      next if target.match?(%r{\A(?:https?://|mailto:|data:)})
      next if target.include?("{{")

      path = target.split("#", 2).first
      resolved = File.expand_path(path, File.dirname(file))
      errors << "#{file}:#{index + 1}: missing local link target #{target}" unless File.exist?(resolved)
    end
  end
end

if errors.empty?
  puts "Markdown local links are valid (#{ARGV.length} files checked)"
  exit 0
end

errors.each { |error| warn error }
exit 1
