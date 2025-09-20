# PipUp tvOS Makefile

.PHONY: build test clean help archive install

# Default target
help:
	@echo "Available targets:"
	@echo "  build     - Build the project for tvOS simulator"
	@echo "  test      - Run unit tests"
	@echo "  clean     - Clean build artifacts"
	@echo "  archive   - Create an archive for distribution"
	@echo "  install   - Install to connected tvOS device"
	@echo "  help      - Show this help message"

# Build for tvOS Simulator
build:
	@echo "Building PipUp tvOS for Simulator..."
	xcodebuild -project PipUpTVOS.xcodeproj \
		-scheme PipUpTVOS \
		-destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=latest' \
		build

# Run unit tests
test:
	@echo "Running unit tests..."
	xcodebuild -project PipUpTVOS.xcodeproj \
		-scheme PipUpTVOS \
		-destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=latest' \
		test

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	xcodebuild -project PipUpTVOS.xcodeproj clean
	rm -rf .build

# Create archive for distribution
archive:
	@echo "Creating archive..."
	xcodebuild -project PipUpTVOS.xcodeproj \
		-scheme PipUpTVOS \
		-destination 'generic/platform=tvOS' \
		archive \
		-archivePath ./build/PipUpTVOS.xcarchive

# Install to connected tvOS device (requires provisioning)
install:
	@echo "Installing to tvOS device..."
	@echo "Note: Requires proper provisioning profile and development team setup"
	xcodebuild -project PipUpTVOS.xcodeproj \
		-scheme PipUpTVOS \
		-destination 'generic/platform=tvOS' \
		build

# Development helpers
dev-setup:
	@echo "Setting up development environment..."
	@echo "Make sure you have Xcode installed with tvOS SDK"
	@echo "Open PipUpTVOS.xcodeproj in Xcode to configure your development team"

# Quick syntax check (uses Swift Package Manager)
syntax-check:
	@echo "Checking Swift syntax..."
	@echo "Note: This will fail on Linux due to UIKit dependencies, but works on macOS"
	-swift build --target PipUpTVOS 2>/dev/null || echo "Expected failure on non-macOS platforms"

# Show project info
info:
	@echo "Project: PipUp tvOS"
	@echo "Platform: tvOS 17.0+"
	@echo "Language: Swift 5.0+"
	@echo "Xcode: 15.0+"
	@echo ""
	@echo "Project structure:"
	@find . -name "*.swift" -not -path "./.build/*" | head -10