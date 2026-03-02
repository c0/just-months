.PHONY: setup generate build open test

setup:
	brew install xcodegen

generate:
	xcodegen generate

build:
	xcodebuild -project BigCalendar.xcodeproj \
	           -scheme BigCalendar \
	           -configuration Release \
	           -derivedDataPath .build

test:
	xcodebuild test \
	           -project BigCalendar.xcodeproj \
	           -scheme BigCalendarTests \
	           -configuration Debug \
	           -derivedDataPath .build

open:
	open BigCalendar.xcodeproj
