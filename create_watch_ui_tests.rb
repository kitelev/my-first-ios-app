#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'my-first-ios-app.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find Watch App target
watch_target = project.targets.find { |t| t.name == 'my-first-ios-app Watch App' }
unless watch_target
  puts "❌ Error: Could not find Watch App target"
  exit 1
end

puts "⌚ Found Watch target: #{watch_target.name}"

# Check if UI test target already exists
test_target_name = 'my-first-ios-app Watch AppUITests'
existing_target = project.targets.find { |t| t.name == test_target_name }

if existing_target
  puts "✅ UI test target already exists: #{test_target_name}"
  exit 0
end

# Create new UI test target
puts "Creating UI test target: #{test_target_name}"
test_target = project.new_target(:ui_test_bundle, test_target_name, :watchos)

# Create test files group
test_group = project.main_group.new_group('my-first-ios-app Watch AppUITests')
test_group.set_source_tree('<group>')

# Add test target to the project
test_target.product_name = test_target_name

# Set build configurations
test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.my-first-ios-app.Watch-AppUITests'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '4' # watchOS
  config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '10.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['TEST_TARGET_NAME'] = 'my-first-ios-app Watch App'
end

# Add dependency on Watch App
test_target.add_dependency(watch_target)
puts "✅ Added Watch App as test dependency"

# Save the project
project.save
puts "\n✅ Watch App UI test target created successfully!"
puts "\nNext steps:"
puts "1. Create test file in 'my-first-ios-app Watch AppUITests' directory"
puts "2. Run tests with: xcodebuild test -scheme '#{test_target_name}' -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'"
