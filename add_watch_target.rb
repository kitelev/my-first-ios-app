#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'my-first-ios-app.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Create Watch App target
watch_target = project.new_target(:watch2_app, 'my-first-ios-app Watch App', :watchos, '9.0')

# Find Watch App group or create it
watch_group = project.main_group.find_subpath('my-first-ios-app Watch App', true)

# Add source files
['ContentView.swift', 'WatchConnectivityManager.swift', 'my_first_ios_app_Watch_AppApp.swift'].each do |filename|
  file_path = "my-first-ios-app Watch App/#{filename}"
  file_ref = watch_group.new_reference(file_path)
  watch_target.add_file_references([file_ref])
end

# Add Assets.xcassets
assets_path = 'my-first-ios-app Watch App/Assets.xcassets'
assets_ref = watch_group.new_reference(assets_path)
watch_target.resources_build_phase.add_file_reference(assets_ref)

# Set build settings
watch_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'ru.kitelev.my-first-ios-app.watchkitapp'
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '4'
  config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '9.0'
  config.build_settings['SDKROOT'] = 'watchos'
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['INFOPLIST_FILE'] = 'my-first-ios-app Watch App/Info.plist'
end

# Save project
project.save

puts "✅ Watch App target added successfully!"
puts "Target: #{watch_target.name}"
puts "Platform: watchOS"
