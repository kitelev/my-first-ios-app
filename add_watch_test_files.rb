#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'my-first-ios-app.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the UI test target
test_target_name = 'my-first-ios-app Watch AppUITests'
test_target = project.targets.find { |t| t.name == test_target_name }

unless test_target
  puts "❌ Error: Could not find test target '#{test_target_name}'"
  exit 1
end

puts "✅ Found test target: #{test_target_name}"

# Find or create the test files group
test_group = project.main_group.groups.find { |g| g.display_name == test_target_name }
unless test_group
  test_group = project.main_group.new_group(test_target_name)
  puts "✅ Created test group: #{test_target_name}"
end

# Add test file to project
test_file_path = "#{test_target_name}/my_first_ios_app_Watch_AppUITests.swift"
file_ref = test_group.new_file(test_file_path)
puts "✅ Added test file reference: #{test_file_path}"

# Add file to compile sources build phase
test_target.source_build_phase.add_file_reference(file_ref)
puts "✅ Added test file to compile sources"

# Save the project
project.save
puts "\n✅ Test files successfully added to project!"
