#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'my-first-ios-app.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find and remove the old test target
test_target_name = 'my-first-ios-app Watch AppUITests'
old_target = project.targets.find { |t| t.name == test_target_name }

if old_target
  puts "Removing old test target: #{test_target_name}"
  project.targets.delete(old_target)

  # Remove test files group
  test_group = project.main_group.groups.find { |g| t.display_name == test_target_name }
  project.main_group.groups.delete(test_group) if test_group

  puts "✅ Old target removed"
end

# Find Watch App target
watch_target = project.targets.find { |t| t.name == 'my-first-ios-app Watch App' }
unless watch_target
  puts "❌ Error: Could not find Watch App target"
  exit 1
end

puts "⌚ Found Watch target: #{watch_target.name}"

# Create new UI test target for watchOS
puts "Creating new watchOS UI test target: #{test_target_name}"

# Create the target with correct settings
test_target = project.new(Xcodeproj::Project::Object::PBXNativeTarget)
test_target.name = test_target_name
test_target.product_name = test_target_name
test_target.product_type = Xcodeproj::Constants::PRODUCT_TYPE_UTI[:ui_test_bundle]

# Create product reference
product_ref = project.products_group.new_reference("#{test_target_name}.xctest")
product_ref.source_tree = 'BUILT_PRODUCTS_DIR'
product_ref.include_in_index = '0'
test_target.product_reference = product_ref

# Add build phases
test_target.build_phases << project.new(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
test_target.build_phases << project.new(Xcodeproj::Project::Object::PBXFrameworksBuildPhase)
test_target.build_phases << project.new(Xcodeproj::Project::Object::PBXResourcesBuildPhase)

# Add test target to project
project.targets << test_target

# Set build configurations
test_target.build_configuration_list = Xcodeproj::Project::Object::XCConfigurationList.new(project)
test_target.build_configuration_list.default_configuration_name = 'Release'

debug_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
debug_config.name = 'Debug'
debug_config.build_settings = {
  'PRODUCT_NAME' => '$(TARGET_NAME)',
  'PRODUCT_BUNDLE_IDENTIFIER' => 'com.example.my-first-ios-app.Watch-AppUITests',
  'TARGETED_DEVICE_FAMILY' => '4',
  'SDKROOT' => 'watchos',
  'WATCHOS_DEPLOYMENT_TARGET' => '10.0',
  'SWIFT_VERSION' => '5.0',
  'CODE_SIGN_STYLE' => 'Automatic',
  'GENERATE_INFOPLIST_FILE' => 'YES',
  'TEST_TARGET_NAME' => 'my-first-ios-app Watch App',
  'ENABLE_BITCODE' => 'YES',
  'INFOPLIST_KEY_CFBundleDisplayName' => test_target_name,
}

release_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
release_config.name = 'Release'
release_config.build_settings = debug_config.build_settings.dup

test_target.build_configuration_list.build_configurations << debug_config
test_target.build_configuration_list.build_configurations << release_config

# Add dependency on Watch App
test_target.add_dependency(watch_target)
puts "✅ Added Watch App as test dependency"

# Create test files group
test_group = project.main_group.new_group(test_target_name)
test_group.set_source_tree('<group>')

# Add test file to project
test_file_path = "#{test_target_name}/my_first_ios_app_Watch_AppUITests.swift"
file_ref = test_group.new_file(test_file_path)
puts "✅ Added test file reference: #{test_file_path}"

# Add file to compile sources build phase
test_target.source_build_phase.add_file_reference(file_ref)
puts "✅ Added test file to compile sources"

# Save the project
project.save
puts "\n✅ Watch App UI test target recreated successfully!"
puts "\nTarget settings:"
puts "  - Platform: watchOS (SDKROOT: watchos)"
puts "  - Device Family: 4 (Apple Watch)"
puts "  - Deployment Target: watchOS 10.0"
