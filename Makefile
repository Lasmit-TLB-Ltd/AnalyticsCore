.PHONY: build test test-macos test-ios test-watchos clean help

# Default target
help:
	@echo "AnalyticsCore Targets:"
	@echo "  make build         - Build the package"
	@echo "  make test          - Run tests on macOS (default)"
	@echo "  make test-macos    - Run tests on macOS"
	@echo "  make test-ios      - Run tests on iOS Simulator"
	@echo "  make test-watchos  - Run tests on watchOS Simulator"
	@echo "  make clean         - Clean build artifacts"

# Build the package
build:
	@echo "🔨 Building AnalyticsCore..."
	@swift build
	@echo "✅ Build complete!"

# Run swift test (runs on macOS)
test: test-macos

# macOS tests (using swift test)
test-macos:
	@echo "🧪 Running tests on macOS..."
	@swift test

# iOS tests (using xcodebuild)
test-ios:
	@echo "📱 Finding available iOS simulators..."
	$(eval SIMULATOR := $(shell xcrun simctl list devices available 'iPhone' | grep -m 1 "iPhone" | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/'))
	@if [ -z "$(SIMULATOR)" ]; then \
		echo "❌ No iOS simulator found. Please install iOS runtime in Xcode."; \
		exit 1; \
	fi
	@echo "✅ Using iOS simulator: $(SIMULATOR)"
	@echo ""
	@echo "🧪 Running tests on iOS..."
	@xcodebuild test \
		-scheme AnalyticsCore \
		-destination "platform=iOS Simulator,id=$(SIMULATOR)" \
		-enableCodeCoverage NO \
		2>&1 | grep -E "(Test Suite|Test Case|Test.*(passed|failed)|Testing (failed|succeeded)|error:)" || true
	@echo ""
	@echo "✅ iOS tests complete!"

# watchOS tests (using xcodebuild)
test-watchos:
	@echo "📱 Finding available watchOS simulators..."
	$(eval SIMULATOR := $(shell xcrun simctl list devices available 'Apple Watch' | grep -m 1 "Apple Watch" | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/'))
	@if [ -z "$(SIMULATOR)" ]; then \
		echo "❌ No watchOS simulator found. Please install watchOS runtime in Xcode."; \
		exit 1; \
	fi
	@echo "✅ Using watchOS simulator: $(SIMULATOR)"
	@echo ""
	@echo "🧪 Running tests on watchOS..."
	@xcodebuild test \
		-scheme AnalyticsCore \
		-destination "platform=watchOS Simulator,id=$(SIMULATOR)" \
		-enableCodeCoverage NO \
		2>&1 | grep -E "(Test Suite|Test Case|Test.*(passed|failed)|Testing (failed|succeeded)|error:)" || true
	@echo ""
	@echo "✅ watchOS tests complete!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@swift package clean
	@rm -rf .build
	@rm -rf *.xcodeproj
	@rm -rf .swiftpm
	@echo "✅ Clean complete!"
