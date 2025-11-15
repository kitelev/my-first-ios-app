#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Adding files..."
/usr/bin/git add .github/workflows/ios-ci.yml

echo "Committing..."
/usr/bin/git commit -m "Fix Watch UI tests to use paired iPhone+Watch simulators"

echo "Pushing..."
/usr/bin/git push origin add-watch-app-target

echo "Done!"
