# MultiSlider
UISlider clone with multiple thumbs and values, and optional snap intervals.

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
    print("\(slider.value)")
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

## Installation

### CocoaPods

```ruby
pod 'MultiSlider'
```

### Manually

Copy `MultiSlider.swift`, `circle@3x.png` and [`MiniLayout.swift`](https://github.com/yonat/MiniLayout) to your Xcode project.

## TODO

- [ ] Horizontal slider and not just vertical.
- [ ] `isContinuous=false` for clients that only want a single `.valueChanged` event on drag end.
- [ ] Fix IB presentation. (images appearing as ?, thumbs not vertically centered)
