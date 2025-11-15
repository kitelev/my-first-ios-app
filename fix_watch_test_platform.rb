#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'my-first-ios-app.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the test target
test_target_name = 'my-first-ios-app Watch AppUITests'
test_target = project.targets.find { |t| t.name == test_target_name }

unless test_target
  puts "❌ Error: Could not find test target '#{test_target_name}'"
  exit 1
end

puts "✅ Found test target: #{test_target_name}"

# Update build settings to use watchOS
test_target.build_configurations.each do |config|
  puts "\nUpdating #{config.name} configuration:"

  # Set watchOS platform
  config.build_settings['SDKROOT'] = 'watchos'
  puts "  ✓ Set SDKROOT to watchos"

  # Set device family to Apple Watch (4)
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '4'
  puts "  ✓ Set TARGETED_DEVICE_FAMILY to 4 (Apple Watch)"

  # Set watchOS deployment target
  config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '10.0'
  puts "  ✓ Set WATCHOS_DEPLOYMENT_TARGET to 10.0"

  # Remove iOS-specific settings if present
  config.build_settings.delete('IPHONEOS_DEPLOYMENT_TARGET')
  puts "  ✓ Removed IPHONEOS_DEPLOYMENT_TARGET"

  # Ensure other watchOS-friendly settings
  config.build_settings['ENABLE_BITCODE'] = 'YES'
  puts "  ✓ Enabled BITCODE"
end

# Save the project
project.save
puts "\n✅ Successfully updated test target to use watchOS platform!"
puts "\nVerify with:"
puts "  xcodebuild -showdestinations -scheme '#{test_target_name}'"
