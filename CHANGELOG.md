# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.10.13] - 2020-12-05

### Fixed
- don't skip first snap marks when the snap values are small.

## [1.10.12] - 2020-09-18

### Changed
- allow using  `outerTrackColor` with a single thumb. (thanks gregorio-michael!)

## [1.10.11] - 2020-06-23

### Fixed
- make `distanceBetweenThumbs` work  when also having a positive `snapStepSize`.

## [1.10.10] - 2020-06-04

### Added
- support larger accessibility text (dynamic type) for value labels.

## [1.10.9] - 2020-04-18

### Added
- add `distanceBetweenThumbs` to specify minimum distance between thumbs.

## [1.10.8] - 2020-03-01

### Fixed
- don't pull-to-dismiss iOS 13 modal when sliding down a vertical slider.

## [1.10.7] - 2020-02-26

### Fixed
- workaround rare layout problems on iOS 12 and 13.

## [1.10.6] - 2020-01-30

### Fixed
- fix crash on iOS 9-10 introduced in 1.10.2 and only partially fixed in 1.10.4.

## [1.10.4] - 2020-01-28

### Fixed
- fix crash on iOS 9-10 introduced in 1.10.2 (but reintroduces issue #36 on these older systems).

## [1.10.3] - 2020-01-22

### Fixed
- don't let thumbs go outside track when slider is horizontal on iOS 12 and 13.

## [1.10.2] - 2020-01-21

### Fixed
- update value labels when there are changes to `valueLabelFormatter`.

## [1.10.1] - 2019-12-29

### Added
- add `isVertical` property that can be used in Interface builder.

## [1.10.0] - 2019-10-24

### Added
- add public access to `draggedThumbIndex` to allow funding which thumb was dragged.

## [1.9.8] - 2019-08-30

### Fixed
- when two thumbs overlap (`keepsDistanceBetweenThumbs == false`) let user drag lower thumb and not only upper thumb.

## [1.9.7] - 2019-08-22

### Added
- support Swift Package Manager.

### Fixed
- fix Interface Builder render error.

## [1.9.6] - 2019-07-13

### Changed
- MiniLayout moved to SweeterSwift.

## [1.9.5] - 2019-07-11

### Added
- add accessibility support.

## [1.9.4] - 2019-06-21

### Changed
- Swift 5, CocoaPods 1.7.

## [1.9.3] - 2019-06-07

### Added
- UIAppearance support.
- turn haptic feedback off by setting `isHapticSnap` to `false`. 

## [1.9.1] - 2019-03-15

### Fixed
- when a slider is in a scroll view, allow both to be dragged.

## [1.9.0] - 2018-12-28

### Added
- range slider: make track color gray below first thumb and above last thumb (configurable through `outerTrackColor`).

## [1.8.2] - 2018-11-06

### Fixed
- fix snap to steps on larger screen sizes (had rounding errors).

## [1.8.0] - 2018-10-25

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
