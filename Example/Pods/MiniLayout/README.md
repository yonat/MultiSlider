# MiniLayout

Minimal AutoLayout convenience layer. Program constraints succinctly.

## Usage

### Put label over textField

```swift
// using MiniLayout:
view.constrain(label, at: .Leading, to: textField)
view.constrain(textField, at: .Top, to: label, at: .Bottom, diff: 8)
 
// without MiniLayout:
view.addConstraint( NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: Equal, toItem: textField, attribute: .Leading, multiplier: 1, constant: 0) )
view.addConstraint( NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: Equal, toItem: label, attribute: .Bottom, multiplier: 1, constant: 8) )
```

### Add button at the center of view

```swift
// using MiniLayout:
view.addConstrainedSubview(button, constrain: .CenterX, .CenterY)
 
// without MiniLayout:
view.addSubview(button)
button.setTranslatesAutoresizingMaskIntoConstraints(false)
view.addConstraint( NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0) )
view.addConstraint( NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0) )
```


## Installation

Just add `MiniLayout.swift` to your project.

Using CocoaPods:

```ruby
pod 'MiniLayout'
```
