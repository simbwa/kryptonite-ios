check:
	set -o pipefail && xcodebuild test -project Kryptonite.xcodeproj -scheme Debug -destination 'platform=iOS Simulator,name=iPhone 6' | tee xcodebuild.log | xcpretty
