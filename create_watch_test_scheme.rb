#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

project_path = 'my-first-ios-app.xcodeproj'
scheme_name = 'my-first-ios-app Watch AppUITests'

# Create schemes directory if it doesn't exist
schemes_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
FileUtils.mkdir_p(schemes_dir)

scheme_file = File.join(schemes_dir, "#{scheme_name}.xcscheme")

# Check if scheme already exists
if File.exist?(scheme_file)
  puts "✅ Scheme already exists: #{scheme_name}"
  exit 0
end

# Create the scheme XML
scheme_xml = <<~XML
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1610"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES"
      buildArchitectures = "Automatic">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "NO"
            buildForArchiving = "NO"
            buildForAnalyzing = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "WATCH_APP_UI_TESTS_TARGET_ID"
               BuildableName = "#{scheme_name}.xctest"
               BlueprintName = "#{scheme_name}"
               ReferencedContainer = "container:my-first-ios-app.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      codeCoverageEnabled = "YES">
      <Testables>
         <TestableReference
            skipped = "NO"
            parallelizable = "YES"
            testExecutionOrdering = "random">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "WATCH_APP_UI_TESTS_TARGET_ID"
               BuildableName = "#{scheme_name}.xctest"
               BlueprintName = "#{scheme_name}"
               ReferencedContainer = "container:my-first-ios-app.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
XML

# Get the actual target ID
project = Xcodeproj::Project.open(project_path)
test_target = project.targets.find { |t| t.name == scheme_name }

unless test_target
  puts "❌ Error: Could not find test target"
  exit 1
end

# Replace placeholder with actual target UUID
scheme_xml.gsub!('WATCH_APP_UI_TESTS_TARGET_ID', test_target.uuid)

# Write the scheme file
File.write(scheme_file, scheme_xml)
puts "✅ Created scheme: #{scheme_name}"
puts "   Location: #{scheme_file}"
