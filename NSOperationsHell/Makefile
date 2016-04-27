APP          = NSOperationsHell
PROJECT      = NSOperationsHell
CONFIG       = Debug
SCHEME       = NSOperationsHell
TARGET      ?= $(APP)
DESTINATION  = "'platform=iOS Simulator,name=iPhone 6s'"

.PHONY: clean
default: test

clean:
	@xcodebuild -sdk iphoneos -project "$(PROJECT).xcodeproj" clean | xcpretty -c
	rm -rf Build build

build: clean
	@xcodebuild -project "$(PROJECT).xcodeproj" -scheme "$(SCHEME)" -configuration "$(CONFIG)" build | xcpretty -c

test: build
	@xcodebuild -project "$(PROJECT).xcodeproj" -scheme "$(SCHEME)" -configuration "$(CONFIG)" -destination "${DESTINATION}" test | xcpretty -c -r junit
