# MultiSlider
UISlider clone with multiple thumbs and values, range highlight, optional snap intervals, optional value labels, either vertical or horizontal.

[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MultiSlider.svg)](https://img.shields.io/cocoapods/v/MultiSlider.svg)
[![Platform](https://img.shields.io/cocoapods/p/MultiSlider.svg?style=flat)](http://cocoapods.org/pods/MultiSlider)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


<p align="center">
<img src="Screenshots/MultiSlider.png">
</p>

## Features

* Multiple thumbs
* Range slider (optional) - track color between thumbs different from track color ouside thumbs
* Vertical (optional)
* Value labels (optional)
* Snap interval (optional)
* Haptic feedback
* Configurable thumb image, minimum and maximum images.
* Configurable track width, color, rounding.

## Usage

```swift
let slider   = MultiSlider()
slider.minimumValue = 1    // default is 0.0
slider.maximumValue = 5    // default is 1.0

slider.value = [1, 4.5, 5]

slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged) // continuous changes
slider.addTarget(self, action: #selector(sliderDragEnded(_:)), for: . touchUpInside) // sent when drag ends
```

### Getting multiple thumb values

```swift
func sliderChanged(slider: MultiSlider) {
    print("\(slider.value)") // e.g., [1.0, 4.5, 5.0]
}
```

### Range slider

```swift
slider.outerTrackColor = .lightGray // outside of first and last thumbs
```

### Vertical / horizontal orientation

```swift
slider.orientation = .horizontal // default is .vertical
```

### Value labels

```swift
slider.valueLabelPosition = .left // .notAnAttribute = don't show labels
slider.isValueLabelRelative = true // show differences between thumbs instead of absolute values
slider.valueLabelFormatter.positiveSuffix = " 𝞵s"
```

### Snap interval

```swift
slider.snapStepSize = 0.5 // default is 0.0, i.e. don't snap
slider.isHapticSnap = false // default is true, i.e. generate haptic feedback when sliding over snap values
```

### Changing Appearance

```swift
slider.tintColor = .cyan // color of track
slider.trackWidth = 32
slider.hasRoundTrackEnds = true
slider.showsThumbImageShadow = false // wide tracks look better without thumb shadow
```

### Images

```swift
slider.thumbImage   = UIImage(named: "balloon")
slider.minimumImage = UIImage(named: "clown")
slider.maximumImage = UIImage(named: "cloud")
```

### Disabling/freezing thumbs

```swift
slider.disabledThumbIndices = [1, 3]
```

## Requirements

- iOS 9.0+
- Xcode 10

## Installation

### CocoaPods:

```ruby
pod 'MultiSlider'
```

Legacy versions:

| Swift version | MultiSlider version |
| :---: | :--- |
| 4.0 (Xcode 9.4) | `pod 'MiniLayout', '~> 1.2.1'`<br>`pod 'MultiSlider', '~> 1.6.0'` |
| 3 | `pod 'MiniLayout', '~> 1.1.0'`<br>`pod 'MultiSlider', '~> 1.1.2'` |
| 2.3 | `pod 'MiniLayout', '~> 1.0.1'`<br>`pod 'MultiSlider', '~> 1.0.1'` |

### Manually:

Copy `Sources/*.swift` and [`MiniLayout.swift`](https://github.com/yonat/MiniLayout) to your Xcode project.

## Meta

[@yonatsharon](https://twitter.com/yonatsharon)

[https://github.com/yonat/MultiSlider](https://github.com/yonat/MultiSlider)

[swift-image]:https://img.shields.io/badge/swift-4.2-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.txt
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
