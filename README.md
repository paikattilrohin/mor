# Mor

Mor is a SwiftUI Morse code learning app built for both iPhone and Apple Watch.

## What is included

- Welcome, instructions, and mode selection screens matching the supplied mockups
- Learn and Test modes
- Dot/dash input from a single press surface
- Scoring, level progression, hearts, accuracy, and high-score tracking
- XcodeGen project setup for iOS + watchOS

## Generate the Xcode project

```bash
xcodegen generate
```

## Run on iPhone Simulator

```bash
xcodebuild -project Mor.xcodeproj -scheme Mor -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Run on Apple Watch Simulator

```bash
xcodebuild -project Mor.xcodeproj -scheme MorWatch -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (42mm),OS=26.1' build
```
