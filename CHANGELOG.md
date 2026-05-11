# Changelog
All notable changes to this project will be documented in this file.

## 2.1.0
* Add UIScene lifecycle support (Flutter 3.38+). Plugin now registers as a
  `FlutterSceneLifeCycleDelegate` and mirrors the existing `UIApplicationDelegate`
  hooks on `scene(_:willConnectTo:options:)`, `scene(_:openURLContexts:)`, and
  `scene(_:continue:)`. Fixes shared URLs not being received once the host
  app adopts UISceneDelegate. Closes #6, #74.
* Bumped minimum Flutter to 3.38.0 and Dart SDK to 3.10.0.
* See README "UIScene lifecycle (Flutter 3.38+) — host app migration notes"
  for required host-app changes (AppDelegate refactor + optional router filter).

## 2.0.4
* Fixed iOS issue #72
* Update README.md

## 2.0.3
* Update README.md iOS setup instructions
* Fixed iOS issues -  #65, #55, #41, #4


## 2.0.2
* Update README.md iOS setup instructions

## 2.0.1
* Update README.md iOS setup instructions

## 2.0.0
* Bug fix for iOS share extension not working in certain scenarios
* Update example app dependencies
* Update plugin dependencies
* Update README.md example code
* Update plugin iOS code


## 1.1.2
* Add support for Apple Privacy Manifest #58


## 1.1.1
* Fixed iOS issue #41
* Update android target SDK to 34
* Update app build.gradle

