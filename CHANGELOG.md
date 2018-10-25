# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- add haptic feedback.

## [1.7.0] - 2018-09-05

### Changed
- Swift 4.2
- animate thumb movement to make it smoother.

### Fixed
- zero-width sliding area in iOS 12 caused all thumbs to be shown on left and crash on drag.

## [1.6.0] - 2018-07-06

### Added
- implement `isContinuous`.
- send `primaryActionTriggered` event in addition to `valueChanged`.

## [1.5.1] - 2018-07-03

### Fixed
- correctly handle non-zero `minimumValue` in horizontal orientation.

## [1.5.0] - 2018-07-01

### Added
- send `.touchUpInside` event when user finished dragging. (thanks benjaminfischer!)

## [1.4.3] - 2018-06-25

### Fixed
- allow drag gesture to start past the edge of the slider, like in standard UISlider.

## [1.4.1] - 2018-05-20

### Changed
- use SwiftLint and SwiftFormat

## [1.4] - 2018-03-01

### Added
- hasRoundTrackEnds (thanks benjaminfischer!)
- showsThumbImageShadow (thanks benjaminfischer!)

## [1.3.1] - 2018-02-24

### Fixed
- Horizontal orientation bugs.

### Changed
- Default label style is borderless.

## [1.3.0] - 2017-11-11

### Added
- set slider orientation as either `.vertical` (default) or `.horizontal`.

## [1.2.0] - 2017-07-15

### Changed
- Swift 4

## [1.1.2] - 2017-05-14

### Fixed
- fix non-rounded values.
