.PHONY: setup generate build open

setup:
	brew install xcodegen

generate:
	xcodegen generate

build:
	xcodebuild -project BigCalendar.xcodeproj \
	           -scheme BigCalendar \
	           -configuration Release \
	           -derivedDataPath .build

open:
	open BigCalendar.xcodeproj
