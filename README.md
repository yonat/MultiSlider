# MultiSlider
UISlider clone with multiple thumbs and values, optional snap intervals, optional value labels.

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
