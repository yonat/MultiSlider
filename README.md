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
* Range slider (optional) - track color between thumbs different from track color outside thumbs
* Vertical (optional)
* Value labels (optional)
* Snap interval (optional)
* Haptic feedback (optional)
* Configurable thumb image, minimum and maximum images.
* Configurable track width, color, rounding.

## Usage

```swift
let slider = MultiSlider()
slider.minimumValue = 1    // default is 0.0
slider.maximumValue = 5    // default is 1.0

slider.value = [1, 4.5, 5]

slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged) // continuous changes
slider.addTarget(self, action: #selector(sliderDragEnded(_:)), for: . touchUpInside) // sent when drag ends
```

### SwiftUI Usage

```swift
MultiValueSlider(value: $valueArray, minimumValue: 1, maximumValue: 5)
```

The properties mentioned below can be used as modifiers, or passed as arguments to the `MultiValueSlider` initializer. For example:

```swift
MultiValueSlider(value: $valueArray, outerTrackColor: .lightGray)
    .thumbTintColor(.blue)
```


### Getting multiple thumb values

Use `value` to get all thumbs values, and `draggedThumbIndex` to find which thumb was last moved.

```swift
func sliderChanged(slider: MultiSlider) {
    print("thumb \(slider.draggedThumbIndex) moved")
    print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
}
```

### Range slider

```swift
slider.outerTrackColor = .lightGray // outside of first and last thumbs
```

### Vertical / horizontal orientation

```swift
slider.orientation = .horizontal // default is .vertical
slider.isVertical = false // same effect, but accessible from Interface Builder
```

### Value labels

```swift
slider.valueLabelPosition = .left // .notAnAttribute = don't show labels
slider.isValueLabelRelative = true // show differences between thumbs instead of absolute values
slider.valueLabelFormatter.positiveSuffix = " 𝞵s"
slider.valueLabelColor = .green
slider.valueLabelFont = someFont
```

For more control over the label text:

```swift
slider.valueLabelTextForThumb = { thumbIndex, thumbValue in
    ["Parasol", "Umbrella"][thumbIndex] + " \(thumbValue)"
}
```

### Snap steps

```swift
slider.snapStepSize = 0.5 // default is 0.0, i.e. don't snap
slider.snapValues = [1, 2, 4, 8] // specify specific snap values instead uniform steps
slider.isHapticSnap = false // default is true, i.e. generate haptic feedback when sliding over snap values
slider.snapImage = UIImage(systemName: "circle.fill") // default: no image
```

### Changing Appearance

```swift
slider.tintColor = .cyan // color of track
slider.thumbTintColor = .blue // color of thumbs
slider.trackWidth = 32
slider.hasRoundTrackEnds = true
slider.showsThumbImageShadow = false // wide tracks look better without thumb shadow
slider.centerThumbOnTrackEnd = true // when thumb value is minimum or maximum, align it's center with the track end instead of its edge
```

### Images

```swift
// add images at the ends of the slider:
slider.minimumImage = UIImage(named: "clown")
slider.maximumImage = UIImage(named: "cloud")

// change image for all thumbs:
slider.thumbImage = UIImage(named: "balloon")

// or let each thumb have a different image:
slider.thumbViews[0].image = UIImage(named: "ball")
slider.thumbViews[1].image = UIImage(named: "club")
```

### Distance/Overlap Between Thumbs

```swift
// allow thumbs to overlap:
slider.keepsDistanceBetweenThumbs = false

// make thumbs keep a greater distance from each other (default = half the thumb size):
slider.distanceBetweenThumbs = 3.14
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

### Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yonat/MultiSlider", from: "1.13.2")
]
```

## Meta

[@yonatsharon](https://twitter.com/yonatsharon)

[https://github.com/yonat/MultiSlider](https://github.com/yonat/MultiSlider)

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.txt
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
