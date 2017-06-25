# MultiSlider
UISlider clone with multiple thumbs and values, optional snap intervals, optional value labels.

[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MultiSlider.svg)](https://img.shields.io/cocoapods/v/MultiSlider.svg)  
[![Platform](https://img.shields.io/cocoapods/p/MultiSlider.svg?style=flat)](http://cocoapods.org/pods/MultiSlider)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

<p align="center">
<img src="Screenshots/MultiSlider.png">
</p>

## Usage

```swift
let slider   = MultiSlider()
slider.minimumValue = 1    // default is 0.0
slider.maximumValue = 5    // default is 1.0
slider.snapStepSize = 0.5  // default is 0.0, i.e. don't snap

slider.value = [1, 4.5, 5]

slider.addTarget(self, action: #selector(sliderChanged(_:)), forControlEvents: .ValueChanged)
```

## Getting Multiple Thumb Values

```swift
func sliderChanged(slider: MultiSlider) {
    print("\(slider.value)") // e.g., [1.0, 4.5, 5.0]
}
```

## Changing Appearance

```swift
slider.thumbImage   = UIImage(named: "baloon")
slider.minimumImage = UIImage(named: "clown")
slider.maximumImage = UIImage(named: "cloud")
slider.trackWidth = 5
slider.tintColor = .cyanColor()
```

## Adding Labels Showing Thumb Value

```swift
slider.valueLabelPosition = .Left // .NotAnAttribute = don't show labels
slider.isValueLabelRelative = true // shows differences instead of absolute values
```

## Disabling/Freezing Thumbs

```swift
slider.disabledThumbIndices = [1, 3]
```

## Requirements

- iOS 8.0+
- Xcode 7.3

## Installation

### CocoaPods:

```ruby
pod 'MultiSlider'
```

For legacy Swift 2.3:

```ruby
pod 'MultiSlider', '~> 1.0.1'
```

### Manually:

Copy `Sources/MultiSlider.swift` and [`MiniLayout.swift`](https://github.com/yonat/MiniLayout) to your Xcode project.

## TODO

- [ ] Horizontal slider and not just vertical.
- [ ] `isContinuous=false` for clients that only want a single `.valueChanged` event on drag end.
- [ ] Fix IB presentation. (dlopen error "image not found", thumbs should be vertically centered and evenly distributed.)

## Meta

[@yonatsharon](https://twitter.com/yonatsharon)

[https://github.com/yonat/MultiSlider](https://github.com/yonat/MultiSlider)

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.txt
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
