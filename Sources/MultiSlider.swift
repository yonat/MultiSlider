//
//  MultiSlider.swift
//  UISlider clone with multiple thumbs and values, and optional snap intervals.
//
//  Created by Yonat Sharon on 14.11.2016.
//  Copyright © 2016 Yonat Sharon. All rights reserved.
//

import UIKit
import MiniLayout

@IBDesignable
public class MultiSlider: UIControl
{
    public var value: [CGFloat] = [] {
        didSet {
            if isSettingValue {return}
            adjustThumbCountToValueCount()
            adjustValuesToStepAndLimits()
            for i in 0 ..< valueLabels.count {
                updateValueLabel(i)
            }
        }
    }

    @IBInspectable public var minimumValue: CGFloat = 0     { didSet {adjustValuesToStepAndLimits()} }
    @IBInspectable public var maximumValue: CGFloat = 1     { didSet {adjustValuesToStepAndLimits()} }

    /// snap thumbs to specific values, evenly spaced. (default = 0: allow any value)
    @IBInspectable public var snapStepSize: CGFloat = 0     { didSet {adjustValuesToStepAndLimits()} }

    @IBInspectable public var thumbCount: Int {
        get {
            return thumbViews.count
        }
        set {
            guard newValue > 0 else {return}
            updateValueCount(newValue)
            adjustThumbCountToValueCount()
        }
    }

    /// make specific thumbs fixed (and grayed)
    public var disabledThumbIndices: Set<Int> = [] {
        didSet {
            for i in 0 ..< thumbCount {
                thumbViews[i].blur(disabledThumbIndices.contains(i))
            }
        }
    }

    /// show value labels next to thumbs. (default: show no label)
    @IBInspectable public var valueLabelPosition: NSLayoutAttribute = .NotAnAttribute {
        didSet {
            valueLabels.removeViewsStartingAt(0)
            if valueLabelPosition != .NotAnAttribute {
                for _ in 0 ..< thumbViews.count {
                    addValueLabel()
                }
            }
        }
    }

    /// value label shows difference from previous thumb value (true) or absolute value (false = default)
    @IBInspectable public var isValueLabelRelative: Bool = false {
        didSet {
            for i in 0 ..< valueLabels.count {
                updateValueLabel(i)
            }
        }
    }

    // MARK: - Appearance

    @IBInspectable public var thumbImage: UIImage? {
        didSet {
            thumbViews.forEach {$0.image = thumbImage}
            let halfHeight = (thumbImage?.size.height ?? 2)/2 - 1 // 1 pixel for semi-transparent boundary
            trackView.layoutMargins = UIEdgeInsets(top: halfHeight, left: 0, bottom: halfHeight, right: 0)
        }
    }
    @IBInspectable public var minimumImage: UIImage? {
        get {
            return minimumView.image
        }
        set {
            minimumView.image = newValue
            layoutTrackEdge(minimumView, edge: .Bottom, superviewEdge: .BottomMargin)
        }
    }
    @IBInspectable public var maximumImage: UIImage? {
        get {
            return maximumView.image
        }
        set {
            maximumView.image = newValue
            layoutTrackEdge(maximumView, edge: .Top, superviewEdge: .TopMargin)
        }
    }
    @IBInspectable public var trackWidth: CGFloat = 2 {
        didSet {
            trackView.removeFirstConstraintWhere {$0.firstAttribute == .Width}
            trackView.constrain(.Width, to: trackWidth)
        }
    }
    public var valueLabelFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.roundingMode = .RoundHalfEven
        return formatter
    }()

    // MARK: - Subviews

    public var thumbViews: [UIImageView] = []
    public var valueLabels: [UITextField] = [] // UILabels are a pain to layout, text fields look nice as-is.
    public var trackView = UIView()
    public var minimumView = UIImageView()
    public var maximumView = UIImageView()

    // MARK: - Actions

    func didDrag(panGesture: UIPanGestureRecognizer) {
        // determine thumb to drag
        if panGesture.state == .Began {
            let location = panGesture.locationInView(slideView)
            var minimumDistance = CGFloat.max
            for i in 0 ..< thumbViews.count {
                guard !disabledThumbIndices.contains(i) else {continue}
                let distance = location.distanceTo(thumbViews[i].center)
                if distance > minimumDistance {break}
                minimumDistance = distance
                if distance < thumbViews[i].diagonalSize {
                    draggedThumbIndex = i
                }
            }
        }
        guard draggedThumbIndex >= 0 else {return}
        defer {
            if panGesture.state == .Ended {
                draggedThumbIndex = -1
            }
        }

        var targetPosition = panGesture.locationInView(slideView).y
        let stepSizeInView = CGFloat(snapStepSize / (maximumValue - minimumValue)) * slideView.bounds.height

        // snap translation to stepSizeInView
        if snapStepSize > 0 {
            targetPosition = targetPosition.rounded(stepSizeInView)
            let translation = targetPosition - thumbViews[draggedThumbIndex].center.y
            guard abs(translation) >= stepSizeInView else {return}
        }

        // don't cross prev/next thumb and total range
        let delta: CGFloat = snapStepSize > 0 ? stepSizeInView : (thumbViews[draggedThumbIndex].frame.height ?? 2e-5) / 2
        let maxLimit = draggedThumbIndex > 0 ? thumbViews[draggedThumbIndex-1].center.y - delta : slideView.bounds.maxY
        let minLimit = draggedThumbIndex < thumbViews.count-1 ? thumbViews[draggedThumbIndex+1].center.y + delta : slideView.bounds.minY
        targetPosition = min(maxLimit, max(targetPosition, minLimit))

        // change corresponding value
        let newValue = maximumValue - (targetPosition / slideView.bounds.height) * (maximumValue - minimumValue)
        guard newValue != value[draggedThumbIndex] else {return}
        isSettingValue = true
        value[draggedThumbIndex] = newValue
        isSettingValue = false

        // update thumb and label
        positionThumbView(draggedThumbIndex)
        if draggedThumbIndex < valueLabels.count {
            updateValueLabel(draggedThumbIndex)
            if isValueLabelRelative && draggedThumbIndex+1 < valueLabels.count {
                updateValueLabel(draggedThumbIndex+1)
            }
        }

        sendActionsForControlEvents(.ValueChanged)
    }

    // MARK: - Privates

    private var slideView = UIView()
    private var isSettingValue = false
    private var draggedThumbIndex: Int = -1
    private lazy var defaultThumbImage: UIImage = .circle(diameter: 29, lineWidth: 0.5, lineColor: UIColor.lightGrayColor().colorWithAlphaComponent(0.5), fillColor: .whiteColor())

    private func setup() {
        trackView.backgroundColor = actualTintColor
        trackView.layer.cornerRadius = 1
        addConstrainedSubview(trackView, constrain: .Top, .Bottom, .CenterXWithinMargins)
        trackView.constrain(.Width, to: trackWidth)
        trackView.addConstrainedSubview(slideView, constrain: .CenterX, .Width, .BottomMargin, .TopMargin)
        slideView.layoutMargins = UIEdgeInsetsZero

        addConstrainedSubview(minimumView, constrain: .BottomMargin, .CenterXWithinMargins)
        addConstrainedSubview(maximumView, constrain: .TopMargin, .CenterXWithinMargins)

        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:))))
    }

    private func adjustThumbCountToValueCount() {
        if value.count == thumbViews.count {
            return
        }
        else if value.count < thumbViews.count {
            thumbViews.removeViewsStartingAt(value.count)
            valueLabels.removeViewsStartingAt(value.count)
        }
        else { // add thumbViews
            for _ in thumbViews.count ..< value.count {
                addThumbView()
            }
        }
    }

    private func addThumbView() {
        let i = thumbViews.count
        let thumbView = UIImageView(image: thumbImage ?? defaultThumbImage)
        thumbView.addShadow()
        thumbViews.append(thumbView)
        slideView.addConstrainedSubview(thumbView, constrain: .CenterX)
        positionThumbView(i)
        thumbView.blur(disabledThumbIndices.contains(i))
        addValueLabel()
    }

    private func addValueLabel() {
        guard valueLabelPosition != .NotAnAttribute else {return}
        let i = valueLabels.count
        let valueLabel = UITextField()
        valueLabel.borderStyle = .RoundedRect
        slideView.addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let thumbView = thumbViews[i]
        slideView.constrain(valueLabel, at: valueLabelPosition.perpendicularCenter, to: thumbView)
        slideView.constrain(valueLabel, at: valueLabelPosition.opposite, to: thumbView, at: valueLabelPosition, diff: -valueLabelPosition.inwardSign * thumbView.diagonalSize / 4)
        valueLabels.append(valueLabel)
        updateValueLabel(i)
    }

    private func updateValueLabel(i: Int) {
        let labelValue: CGFloat
        if isValueLabelRelative {
            labelValue = i > 0 ? value[i] - value[i-1] : value[i] - minimumValue
        }
        else {
            labelValue = value[i]
        }
        valueLabels[i].text = valueLabelFormatter.stringFromNumber(labelValue)
    }

    private func updateValueCount(count: Int) {
        guard count != value.count else {return}
        isSettingValue = true
        if value.count < count {
            let appendCount = count - value.count
            var startValue = value.last ?? minimumValue
            let length = maximumValue - startValue
            let relativeStepSize = snapStepSize / (maximumValue - minimumValue)
            var step: CGFloat = 0
            if 0 == value.count && 1 < appendCount {
                step = ( length / CGFloat(appendCount-1) ).truncated(relativeStepSize)
            }
            else {
                step = ( length / CGFloat(appendCount) ).truncated(relativeStepSize)
                if 0 < value.count {
                    startValue += step
                }
            }
            if 0 == step {step = relativeStepSize}
            value += startValue.stride(through: maximumValue, by: step)
        }
        if value.count > count { // don't add "else", since prev calc may add too many values in some cases
            value.removeLast(value.count - count)
        }

        isSettingValue = false
    }

    private func adjustValuesToStepAndLimits() {
        var adjusted = value.sort()
        for i in 0..<adjusted.count {
            let snapped = adjusted[i].rounded(snapStepSize)
            adjusted[i] = min(maximumValue, max(minimumValue, snapped))
        }

        isSettingValue = true
        value = adjusted
        isSettingValue = false

        for i in 0..<value.count {
            positionThumbView(i)
        }
    }

    private func positionThumbView(i: Int) {
        let thumbView = thumbViews[i]
        let thumbValue = value[i]
        slideView.removeFirstConstraintWhere {$0.firstItem === thumbView && $0.firstAttribute == .CenterY}
        let thumbRelativeY = (maximumValue - thumbValue) / (maximumValue - minimumValue)
        if thumbRelativeY.isNormal {
            slideView.constrain(thumbView, at: .CenterY, to: slideView, at: .Bottom, ratio: CGFloat(thumbRelativeY))
        }
        else {
            slideView.constrain(thumbView, at: .CenterY, to: slideView, at: .Top)
        }
        UIView.animateWithDuration(0.1) {
            self.slideView.layoutIfNeeded()
        }
    }

    private func layoutTrackEdge(toView: UIImageView, edge: NSLayoutAttribute, superviewEdge: NSLayoutAttribute) {
        removeFirstConstraintWhere {$0.firstItem === self.trackView && ($0.firstAttribute == edge || $0.firstAttribute == superviewEdge)}
        if nil != toView.image {
            constrain(trackView, at: edge, to: toView, at: edge.opposite, diff: edge.inwardSign*8)
        }
        else {
            constrain(trackView, at: edge, to: self, at: superviewEdge)
        }
    }

    // MARK: - Overrides

    override public func tintColorDidChange() {
        let thumbTint = thumbViews.map {$0.tintColor} // different thumbs may have different tints
        super.tintColorDidChange()
        trackView.backgroundColor = actualTintColor
        for (thumbView, tint) in zip(thumbViews, thumbTint) {
            thumbView.tintColor = tint
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public func prepareForInterfaceBuilder() {
        // make visual editing easier
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor

        // evenly distribue thumbs
        let oldThumbCount = thumbCount
        thumbCount = 0
        thumbCount = oldThumbCount
    }
}

// MARK: Extensions

extension CGFloat {
    func truncated(step: CGFloat) -> CGFloat {
        return step.isNormal ? self - (self % step) : self
    }
    func rounded(step: CGFloat) -> CGFloat {
        guard step.isNormal && self.isNormal else {return self}
        let remainder = self % step
        let truncated = self - remainder
        return remainder * 2 < step ? truncated : truncated + step
    }
}

extension CGPoint {
    func distanceTo(point: CGPoint) -> CGFloat {
        let (dx, dy) = (x - point.x, y - point.y)
        return hypot(dx, dy)
    }
}

extension UIView {
    var diagonalSize: CGFloat {return hypot(frame.width, frame.height)}

    var actualTintColor: UIColor {
        var tintedView: UIView? = self
        while let currentView = tintedView where nil == currentView.tintColor {
            tintedView = currentView.superview
        }
        return tintedView?.tintColor ?? .blueColor()
    }

    func removeFirstConstraintWhere(predicate: (constraint: NSLayoutConstraint) -> Bool) {
        if let constrainIndex = constraints.indexOf(predicate) {
            removeConstraint(constraints[constrainIndex])
        }
    }

    func addShadow() {
        layer.shadowColor = UIColor.grayColor().CGColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 0.5
    }
}

extension Array where Element: UIView {
    mutating func removeViewsStartingAt(index: Int) {
        guard index >= 0 && index < count else {return}
        self[index ..< count].forEach {$0.removeFromSuperview()}
        removeLast(count - index)
    }
}

extension UIImageView {
    func blur(on: Bool) {
        if on {
            guard nil == viewWithTag(UIImageView.blurViewTag) else {return}
            let blurImage = image?.imageWithRenderingMode(.AlwaysTemplate)
            let blurView = UIImageView(image: blurImage)
            blurView.tag = UIImageView.blurViewTag
            blurView.tintColor = .whiteColor()
            blurView.alpha = 0.5
            addConstrainedSubview(blurView, constrain: .Top, .Bottom, .Left, .Right)
            layer.shadowOpacity /= 2
        }
        else {
            guard let blurView = viewWithTag(UIImageView.blurViewTag) else {return}
            blurView.removeFromSuperview()
            layer.shadowOpacity *= 2
        }
    }
    static var blurViewTag: Int {return 898989}
}

extension NSLayoutAttribute {
    var opposite: NSLayoutAttribute {
        switch self {
        case .Left: return .Right
        case .Right: return .Left
        case .Top: return .Bottom
        case .Bottom: return .Top
        case .Leading: return .Trailing
        case .Trailing: return .Leading
        case .LeftMargin: return .RightMargin
        case .RightMargin: return .LeftMargin
        case .TopMargin: return .BottomMargin
        case .BottomMargin: return .TopMargin
        case .LeadingMargin: return .TrailingMargin
        case .TrailingMargin: return .LeadingMargin
        default: return self
        }
    }

    var inwardSign: CGFloat {
        switch self {
        case .Top, .TopMargin: return 1
        case .Bottom, .BottomMargin: return -1
        case .Left, .Leading, .LeftMargin, .LeadingMargin: return 1
        case .Right, .Trailing, .RightMargin, .TrailingMargin: return -1
        default: return 1
        }
    }

    var perpendicularCenter: NSLayoutAttribute {
        switch self {
        case .Left, .Leading, .LeftMargin, .LeadingMargin, .Right, .Trailing, .RightMargin, .TrailingMargin: return .CenterY
        default: return .CenterY
        }
    }
}

extension UIImage {
    static func circle(diameter diameter: CGFloat, lineWidth: CGFloat = 1, lineColor: UIColor? = nil, fillColor: UIColor? = nil) -> UIImage {
        let circleLayer = CAShapeLayer()
        circleLayer.fillColor = fillColor?.CGColor
        circleLayer.strokeColor = lineColor?.CGColor
        circleLayer.lineWidth = lineWidth
        let margin = lineWidth * 2
        let circle = UIBezierPath(ovalInRect: CGRect(x: margin, y: margin, width: diameter, height: diameter))
        circleLayer.bounds = CGRect(x: 0, y: 0, width: diameter + margin*2, height: diameter + margin*2)
        circleLayer.path = circle.CGPath
        UIGraphicsBeginImageContextWithOptions(circleLayer.bounds.size, false, 0)
        circleLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image =  UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
