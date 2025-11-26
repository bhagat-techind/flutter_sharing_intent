#!/bin/bash

echo "🚿 Cleaning Flutter project..."

# Flutter clean
flutter clean

# Remove Dart & Flutter tool directories
rm -rf .dart_tool
rm -rf build
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
rm -rf .packages
rm -rf pubspec.lock

# iOS cleanup
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Podfile.lock
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Generated.xcconfig

# Android cleanup
#rm -rf android/.gradle
rm -rf android/build

# Run pub get again
flutter pub get

echo "✅ Project cleaned successfully!"
