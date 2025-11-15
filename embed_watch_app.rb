#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'my-first-ios-app.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find iOS app target
ios_target = project.targets.find { |t| t.name == 'my-first-ios-app' }
unless ios_target
  puts "❌ Error: Could not find iOS app target"
  exit 1
end

# Find Watch App target
watch_target = project.targets.find { |t| t.name == 'my-first-ios-app Watch App' }
unless watch_target
  puts "❌ Error: Could not find Watch App target"
  exit 1
end

puts "📱 iOS target: #{ios_target.name}"
puts "⌚ Watch target: #{watch_target.name}"

# Add Watch App as dependency to iOS app
ios_target.add_dependency(watch_target)
puts "✅ Added Watch App as dependency"

# Find or create "Embed Watch Content" build phase
embed_phase = ios_target.copy_files_build_phases.find do |phase|
  phase.name == 'Embed Watch Content'
end

unless embed_phase
  embed_phase = ios_target.new_copy_files_build_phase('Embed Watch Content')
  embed_phase.symbol_dst_subfolder_spec = :products_directory
  embed_phase.dst_path = '$(CONTENTS_FOLDER_PATH)/Watch'
  puts "✅ Created 'Embed Watch Content' build phase"
end

# Add Watch App product to embed phase
watch_product = watch_target.product_reference
build_file = embed_phase.add_file_reference(watch_product)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
puts "✅ Added Watch App to embed phase"

# Update iOS app build settings
ios_target.build_configurations.each do |config|
  config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
end
puts "✅ Updated iOS app build settings"

# Save project
project.save
puts "\n✅ Watch App successfully embedded in iOS app!"
puts "\nNext steps:"
puts "1. Build and install iOS app: xcodebuild -scheme my-first-ios-app -destination 'id=YOUR_IPHONE_ID' install"
puts "2. Watch App will be automatically installed on paired Apple Watch"
