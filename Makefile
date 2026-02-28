.PHONY: setup generate build open dev local-release release

setup:
	brew install xcodegen

generate:
	xcodegen generate

build:
	xcodebuild -project JustMonths.xcodeproj \
	           -scheme JustMonths \
	           -configuration Release \
	           -derivedDataPath .build

open:
	open JustMonths.xcodeproj

dev:
	xcodebuild -project JustMonths.xcodeproj -scheme JustMonths \
	           -configuration Debug -derivedDataPath .build build \
	  && open .build/Build/Products/Debug/JustMonths.app

local-release:
	xcodebuild -project JustMonths.xcodeproj -scheme JustMonths \
	           -configuration LocalRelease -derivedDataPath .build

release:
	@[ -f .env ] || (echo "ERROR: .env not found. Copy .env.example."; exit 1)
	@bash scripts/release.sh $(VERSION)
