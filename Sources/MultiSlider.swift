//
//  MultiSlider.swift
//  UISlider clone with multiple thumbs and values, and optional snap intervals.
//
//  Created by Yonat Sharon on 14.11.2016.
//  Copyright © 2016 Yonat Sharon. All rights reserved.
//

import AvailableHapticFeedback
import MiniLayout
import UIKit

@IBDesignable
open class MultiSlider: UIControl {
    @objc open var value: [CGFloat] = [] {
        didSet {
            if isSettingValue { return }
            adjustThumbCountToValueCount()
            adjustValuesToStepAndLimits()
            for i in 0 ..< valueLabels.count {
                updateValueLabel(i)
            }
        }
    }

    @IBInspectable open var minimumValue: CGFloat = 0 { didSet { adjustValuesToStepAndLimits() } }
    @IBInspectable open var maximumValue: CGFloat = 1 { didSet { adjustValuesToStepAndLimits() } }
    @IBInspectable open var isContinuous: Bool = true

    /// snap thumbs to specific values, evenly spaced. (default = 0: allow any value)
    @IBInspectable open var snapStepSize: CGFloat = 0 { didSet { adjustValuesToStepAndLimits() } }

    @IBInspectable open var thumbCount: Int {
        get {
            return thumbViews.count
        }
        set {
            guard newValue > 0 else { return }
            updateValueCount(newValue)
            adjustThumbCountToValueCount()
        }
    }

    /// make specific thumbs fixed (and grayed)
    @objc open var disabledThumbIndices: Set<Int> = [] {
        didSet {
            for i in 0 ..< thumbCount {
                thumbViews[i].blur(disabledThumbIndices.contains(i))
            }
        }
    }

    /// show value labels next to thumbs. (default: show no label)
    @objc open var valueLabelPosition: NSLayoutConstraint.Attribute = .notAnAttribute {
        didSet {
            valueLabels.removeViewsStartingAt(0)
            if valueLabelPosition != .notAnAttribute {
                for i in 0 ..< thumbViews.count {
                    addValueLabel(i)
                }
            }
        }
    }

    /// value label shows difference from previous thumb value (true) or absolute value (false = default)
    @IBInspectable open var isValueLabelRelative: Bool = false {
        didSet {
            for i in 0 ..< valueLabels.count {
                updateValueLabel(i)
            }
        }
    }

    // MARK: - Appearance

    @objc open var orientation: NSLayoutConstraint.Axis = .vertical {
        didSet {
            setupOrientation()
            invalidateIntrinsicContentSize()
            repositionThumbViews()
        }
    }

    /// track color before first thumb and after last thumb. `nil` means to use the tintColor, like the rest of the track.
    @IBInspectable open var outerTrackColor: UIColor? {
        didSet {
            updateOuterTrackViews()
        }
    }

    @IBInspectable open var thumbImage: UIImage? {
        didSet {
            thumbViews.forEach { $0.image = thumbImage }
            setupTrackLayoutMargins()
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable public var showsThumbImageShadow: Bool = true {
        didSet {
            updateThumbViewShadowVisibility()
        }
    }

    @IBInspectable open var minimumImage: UIImage? {
        get {
            return minimumView.image
        }
        set {
            minimumView.image = newValue
            layoutTrackEdge(
                toView: minimumView,
                edge: .bottom(in: orientation),
                superviewEdge: orientation == .vertical ? .bottomMargin : .leadingMargin
            )
        }
    }

    @IBInspectable open var maximumImage: UIImage? {
        get {
            return maximumView.image
        }
        set {
            maximumView.image = newValue
            layoutTrackEdge(
                toView: maximumView,
                edge: .top(in: orientation),
                superviewEdge: orientation == .vertical ? .topMargin : .trailingMargin
            )
        }
    }

    @IBInspectable open var trackWidth: CGFloat = 2 {
        didSet {
            let widthAttribute: NSLayoutConstraint.Attribute = orientation == .vertical ? .width : .height
            trackView.removeFirstConstraint { $0.firstAttribute == widthAttribute }
            trackView.constrain(widthAttribute, to: trackWidth)
            updateTrackViewCornerRounding()
        }
    }

    @IBInspectable public var hasRoundTrackEnds: Bool = true {
        didSet {
            updateTrackViewCornerRounding()
        }
    }

    @IBInspectable public var keepsDistanceBetweenThumbs: Bool = true

    open var valueLabelFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.roundingMode = .halfEven
        return formatter
    }()

    // MARK: - Subviews

    @objc open var thumbViews: [UIImageView] = []
    @objc open var valueLabels: [UITextField] = [] // UILabels are a pain to layout, text fields look nice as-is.
    @objc open var trackView = UIView()
    @objc open var outerTrackViews: [UIView] = []
    @objc open var minimumView = UIImageView()
    @objc open var maximumView = UIImageView()

    // MARK: - Internals

    let slideView = UIView()
    let panGestureView = UIView()
    let margin: CGFloat = 32
    var isSettingValue = false
    var draggedThumbIndex: Int = -1
    lazy var defaultThumbImage: UIImage? = .circle(diameter: 29, width: 0.5, color: UIColor.lightGray.withAlphaComponent(0.5), fill: .white)
    var selectionFeedbackGenerator = AvailableHapticFeedback()

    private func setup() {
        trackView.backgroundColor = actualTintColor
        updateTrackViewCornerRounding()
        slideView.layoutMargins = .zero
        setupOrientation()
        setupPanGesture()
    }

    private func setupPanGesture() {
        addConstrainedSubview(panGestureView)
        for edge: NSLayoutConstraint.Attribute in [.top, .bottom, .left, .right] {
            constrain(panGestureView, at: edge, diff: -edge.inwardSign * margin)
        }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:)))
        panGesture.delegate = self
        panGestureView.addGestureRecognizer(panGesture)
    }

    private func setupOrientation() {
        trackView.removeFromSuperview()
        trackView.removeConstraints(trackView.constraints)
        slideView.removeFromSuperview()
        minimumView.removeFromSuperview()
        maximumView.removeFromSuperview()
        switch orientation {
        case .vertical:
            addConstrainedSubview(trackView, constrain: .top, .bottom, .centerXWithinMargins)
            trackView.constrain(.width, to: trackWidth)
            trackView.addConstrainedSubview(slideView, constrain: .left, .right, .bottomMargin, .topMargin)
            addConstrainedSubview(minimumView, constrain: .bottomMargin, .centerXWithinMargins)
            addConstrainedSubview(maximumView, constrain: .topMargin, .centerXWithinMargins)
        case .horizontal:
            addConstrainedSubview(trackView, constrain: .left, .right, .centerYWithinMargins)
            trackView.constrain(.height, to: trackWidth)
            if #available(iOS 12, *) {
                trackView.addConstrainedSubview(slideView, constrain: .top, .bottom, .left, .right) // iOS 12 β doesn't like .leftMargin, .rightMargin
            } else {
                trackView.addConstrainedSubview(slideView, constrain: .top, .bottom, .leftMargin, .rightMargin)
            }
            addConstrainedSubview(minimumView, constrain: .leftMargin, .centerYWithinMargins)
            addConstrainedSubview(maximumView, constrain: .rightMargin, .centerYWithinMargins)
        }
        setupTrackLayoutMargins()
    }

    private func setupTrackLayoutMargins() {
        let thumbSize = (thumbImage ?? defaultThumbImage)?.size ?? CGSize(width: 2, height: 2)
        let thumbDiameter = orientation == .vertical ? thumbSize.height : thumbSize.width
        let halfThumb = thumbDiameter / 2 - 1 // 1 pixel for semi-transparent boundary
        if orientation == .vertical {
            trackView.layoutMargins = UIEdgeInsets(top: halfThumb, left: 0, bottom: halfThumb, right: 0)
        } else {
            trackView.layoutMargins = UIEdgeInsets(top: 0, left: halfThumb, bottom: 0, right: halfThumb)
        }
    }

    private func repositionThumbViews() {
        thumbViews.forEach { $0.removeFromSuperview() }
        thumbViews = []
        valueLabels.forEach { $0.removeFromSuperview() }
        valueLabels = []
        adjustThumbCountToValueCount()
    }

    private func adjustThumbCountToValueCount() {
        if value.count == thumbViews.count {
            return
        } else if value.count < thumbViews.count {
            thumbViews.removeViewsStartingAt(value.count)
            valueLabels.removeViewsStartingAt(value.count)
        } else { // add thumbViews
            for _ in thumbViews.count ..< value.count {
                addThumbView()
            }
        }
        updateOuterTrackViews()
    }

    private func updateOuterTrackViews() {
        outerTrackViews.removeViewsStartingAt(0)
        outerTrackViews.removeAll()
        guard nil != outerTrackColor else { return }
        guard let firstThumb = thumbViews.first, let lastThumb = thumbViews.last, firstThumb != lastThumb else { return }

        outerTrackViews = [
            outerTrackView(constraining: .top(in: orientation), to: firstThumb),
            outerTrackView(constraining: .bottom(in: orientation), to: lastThumb),
        ]
    }

    private func outerTrackView(constraining: NSLayoutConstraint.Attribute, to thumbView: UIView) -> UIView {
        let view = UIView()
        view.backgroundColor = outerTrackColor
        trackView.addConstrainedSubview(view, constrain: .top, .bottom, .leading, .trailing)
        trackView.removeFirstConstraint { $0.firstItem === view && $0.firstAttribute == constraining }
        trackView.constrain(view, at: constraining, to: thumbView, at: .center(in: orientation))
        trackView.sendSubviewToBack(view)

        view.layer.cornerRadius = trackView.layer.cornerRadius
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = .direction(constraining.opposite)
        }

        return view
    }

    private func addThumbView() {
        let i = thumbViews.count
        let thumbView = UIImageView(image: thumbImage ?? defaultThumbImage)
        thumbView.addShadow()
        thumbViews.append(thumbView)
        slideView.addConstrainedSubview(thumbView, constrain: NSLayoutConstraint.Attribute.center(in: orientation).perpendicularCenter)
        positionThumbView(i)
        thumbView.blur(disabledThumbIndices.contains(i))
        addValueLabel(i)
        updateThumbViewShadowVisibility()
    }

    private func updateThumbViewShadowVisibility() {
        thumbViews.forEach {
            $0.layer.shadowOpacity = showsThumbImageShadow ? 0.25 : 0
        }
    }

    private func addValueLabel(_ i: Int) {
        guard valueLabelPosition != .notAnAttribute else { return }
        let valueLabel = UITextField()
        valueLabel.borderStyle = .none
        slideView.addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let thumbView = thumbViews[i]
        slideView.constrain(valueLabel, at: valueLabelPosition.perpendicularCenter, to: thumbView)
        slideView.constrain(
            valueLabel, at: valueLabelPosition.opposite,
            to: thumbView, at: valueLabelPosition,
            diff: -valueLabelPosition.inwardSign * thumbView.diagonalSize / 4
        )
        valueLabels.append(valueLabel)
        updateValueLabel(i)
    }

    func updateValueLabel(_ i: Int) {
        let labelValue: CGFloat
        if isValueLabelRelative {
            labelValue = i > 0 ? value[i] - value[i - 1] : value[i] - minimumValue
        } else {
            labelValue = value[i]
        }
        valueLabels[i].text = valueLabelFormatter.string(from: NSNumber(value: Double(labelValue)))
    }

    private func updateValueCount(_ count: Int) {
        guard count != value.count else { return }
        isSettingValue = true
        if value.count < count {
            let appendCount = count - value.count
            var startValue = value.last ?? minimumValue
            let length = maximumValue - startValue
            let relativeStepSize = snapStepSize / (maximumValue - minimumValue)
            var step: CGFloat = 0
            if 0 == value.count && 1 < appendCount {
                step = (length / CGFloat(appendCount - 1)).truncated(relativeStepSize)
            } else {
                step = (length / CGFloat(appendCount)).truncated(relativeStepSize)
                if 0 < value.count {
                    startValue += step
                }
            }
            if 0 == step { step = relativeStepSize }
            value += stride(from: startValue, through: maximumValue, by: step)
        }
        if value.count > count { // don't add "else", since prev calc may add too many values in some cases
            value.removeLast(value.count - count)
        }

        isSettingValue = false
    }

    private func adjustValuesToStepAndLimits() {
        var adjusted = value.sorted()
        for i in 0 ..< adjusted.count {
            let snapped = adjusted[i].rounded(snapStepSize)
            adjusted[i] = min(maximumValue, max(minimumValue, snapped))
        }

        isSettingValue = true
        value = adjusted
        isSettingValue = false

        for i in 0 ..< value.count {
            positionThumbView(i)
        }
    }

    func positionThumbView(_ i: Int) {
        let thumbView = thumbViews[i]
        let thumbValue = value[i]
        slideView.removeFirstConstraint { $0.firstItem === thumbView && $0.firstAttribute == .center(in: orientation) }
        let thumbRelativeDistanceToMax = (maximumValue - thumbValue) / (maximumValue - minimumValue)
        if orientation == .horizontal {
            if thumbRelativeDistanceToMax < 1 {
                slideView.constrain(thumbView, at: .centerX, to: slideView, at: .right, ratio: CGFloat(1 - thumbRelativeDistanceToMax))
            } else {
                slideView.constrain(thumbView, at: .centerX, to: slideView, at: .left)
            }
        } else { // vertical orientation
            if thumbRelativeDistanceToMax.isNormal {
                slideView.constrain(thumbView, at: .centerY, to: slideView, at: .bottom, ratio: CGFloat(thumbRelativeDistanceToMax))
            } else {
                slideView.constrain(thumbView, at: .centerY, to: slideView, at: .top)
            }
        }
        UIView.animate(withDuration: 0.1) {
            self.slideView.updateConstraintsIfNeeded()
        }
    }

    private func layoutTrackEdge(toView: UIImageView, edge: NSLayoutConstraint.Attribute, superviewEdge: NSLayoutConstraint.Attribute) {
        removeFirstConstraint { $0.firstItem === self.trackView && ($0.firstAttribute == edge || $0.firstAttribute == superviewEdge) }
        if nil != toView.image {
            constrain(trackView, at: edge, to: toView, at: edge.opposite, diff: edge.inwardSign * 8)
        } else {
            constrain(trackView, at: edge, to: self, at: superviewEdge)
        }
    }

    private func updateTrackViewCornerRounding() {
        trackView.layer.cornerRadius = hasRoundTrackEnds ? trackWidth / 2 : 1
        outerTrackViews.forEach { $0.layer.cornerRadius = trackView.layer.cornerRadius }
    }

    // MARK: - Overrides

    open override func tintColorDidChange() {
        let thumbTint = thumbViews.map { $0.tintColor } // different thumbs may have different tints
        super.tintColorDidChange()
        trackView.backgroundColor = actualTintColor
        for (thumbView, tint) in zip(thumbViews, thumbTint) {
            thumbView.tintColor = tint
        }
    }

    open override var intrinsicContentSize: CGSize {
        let thumbSize = (thumbImage ?? defaultThumbImage)?.size ?? CGSize(width: margin, height: margin)
        switch orientation {
        case .vertical:
            return CGSize(width: thumbSize.width + margin, height: UIView.noIntrinsicMetric)
        case .horizontal:
            return CGSize(width: UIView.noIntrinsicMetric, height: thumbSize.height + margin)
        }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || alpha == 0 { return nil }
        if clipsToBounds { return super.hitTest(point, with: event) }
        return panGestureView.hitTest(panGestureView.convert(point, from: self), with: event)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        // make visual editing easier
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor

        // evenly distribute thumbs
        let oldThumbCount = thumbCount
        thumbCount = 0
        thumbCount = oldThumbCount
    }
}
