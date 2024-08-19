//
//  MultiSlider.swift
//  UISlider clone with multiple thumbs and values, and optional snap intervals.
//
//  Created by Yonat Sharon on 14.11.2016.
//  Copyright © 2016 Yonat Sharon. All rights reserved.
//

import SweeterSwift
import UIKit

@IBDesignable
open class MultiSlider: UIControl {
    @objc open var value: [CGFloat] = [] {
        didSet {
            if isSettingValue { return }
            value.sort()
            adjustThumbCountToValueCount()
            adjustValuesToStepAndLimits()
            updateAllValueLabels()
            accessibilityValue = value.description
        }
    }

    @IBInspectable open dynamic var minimumValue: CGFloat = 0 { didSet { adjustValuesToStepAndLimits() } }
    @IBInspectable open dynamic var maximumValue: CGFloat = 1 { didSet { adjustValuesToStepAndLimits() } }
    @IBInspectable open dynamic var isContinuous: Bool = true

    // MARK: - Multiple Thumbs

    @objc public internal(set) var draggedThumbIndex: Int = -1

    @IBInspectable open dynamic var thumbCount: Int {
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

    /// minimal distance to keep between thumbs (half a thumb by default)
    @IBInspectable public dynamic var distanceBetweenThumbs: CGFloat = -1

    @IBInspectable public dynamic var keepsDistanceBetweenThumbs: Bool {
        get { return distanceBetweenThumbs != 0 }
        set {
            if keepsDistanceBetweenThumbs != newValue {
                distanceBetweenThumbs = newValue ? -1 : 0
            }
        }
    }

    // MARK: - Snap to Discrete Values

    /// snap thumbs to specific values, evenly spaced. (default = 0: allow any value)
    @IBInspectable open dynamic var snapStepSize: CGFloat {
        get {
            switch snap {
            case let .stepSize(stepSize): return stepSize
            default: return 0
            }
        }
        set {
            snap = newValue.isNormal ? .stepSize(newValue) : .never
        }
    }

    /// snap thumbs to specific values. changes `minimumValue` and `maximumValue`.  (default = []: allow any value)
    @objc open dynamic var snapValues: [CGFloat] {
        get {
            switch snap {
            case .never:
                return []
            case let .stepSize(stepSize):
                return Array(stride(from: minimumValue, to: maximumValue, by: stepSize)) + [maximumValue]
            case let .values(values):
                return values
            }
        }
        set {
            snap = .values(newValue)
        }
    }

    /// image to show at each snap value
    @IBInspectable open dynamic var snapImage: UIImage? {
        didSet {
            setupTrackLayoutMargins()

            guard snapValues.count > 2 else { return }
            if let snapImage = snapImage {
                if nil != oldValue {
                    snapViews.forEach { $0.image = snapImage }
                } else {
                    snapValues.forEach { addSnapView(at: $0) }
                }
            } else {
                snapViews.removeAllViews()
            }
        }
    }

    /// Snapping behavior: How should the slider snap thumbs to discrete values
    public enum Snap: Equatable {
        /// No snapping, slider continuously.
        case never
        /// Snap to values separated by a constant step, starting from `minimumValue`. Equivalent to setting `snapStepSize`.
        case stepSize(CGFloat)
        /// Snap to the specified values. Equivalent to setting `snapValues`.
        case values([CGFloat])
    }

    /// Snapping behavior: How should the slider snap thumbs to discrete values
    open dynamic var snap: Snap = .never {
        didSet {
            if case let .values(values) = snap {
                if values.isEmpty {
                    snap = .never
                } else {
                    var sorted = values.sorted()
                    if minimumValue > values.first! {
                        minimumValue = sorted.first!
                    } else if minimumValue < sorted.first! {
                        sorted.insert(minimumValue, at: 0)
                    }
                    if maximumValue < values.last! {
                        maximumValue = sorted.last!
                    } else if maximumValue > sorted.last! {
                        sorted.append(maximumValue)
                    }
                    snap = .values(sorted)
                }
            }
            adjustValuesToStepAndLimits()
        }
    }

    /// generate haptic feedback when hitting snap steps
    @IBInspectable open dynamic var isHapticSnap: Bool {
        get {
            selectionFeedbackGenerator != nil
        }
        set {
            selectionFeedbackGenerator = newValue ? UISelectionFeedbackGenerator() : nil
            selectionFeedbackGenerator?.prepare()
        }
    }

    // MARK: - Value Labels

    /// value label shows difference from previous thumb value (true) or absolute value (false = default)
    @IBInspectable open dynamic var isValueLabelRelative: Bool = false {
        didSet {
            updateAllValueLabels()
        }
    }

    /// show value labels next to thumbs. (default: show no label)
    @objc open dynamic var valueLabelPosition: NSLayoutConstraint.Attribute = .notAnAttribute {
        didSet {
            updateValueLabelPosition()
        }
    }

    /// show every other value label opposite of the value label position.
    /// e.g., If you set `valueLabelPosition` to `.top`, the second value label position would be `.bottom`.
    @IBInspectable open dynamic var valueLabelAlternatePosition: Bool = false {
        didSet {
            updateValueLabelPosition()
        }
    }

    @IBInspectable open dynamic var valueLabelColor: UIColor? {
        didSet {
            valueLabels.forEach { $0.textColor = valueLabelColor }
        }
    }

    open dynamic var valueLabelFont: UIFont? {
        didSet {
            valueLabels.forEach { $0.font = valueLabelFont }
        }
    }

    @objc open dynamic var valueLabelFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.roundingMode = .halfEven
        return formatter
    }() {
        didSet {
            updateAllValueLabels()
            if #available(iOS 11.0, *) {
                oldValue.removeObserverForAllProperties(observer: self)
                valueLabelFormatter.addObserverForAllProperties(observer: self)
            }
        }
    }

    /// Return value label text for a thumb index and value. If `nil`, then `valueLabelFormatter` will be used instead.
    @objc open dynamic var valueLabelTextForThumb: ((Int, CGFloat) -> String?)? {
        didSet {
            for i in valueLabels.indices {
                updateValueLabel(i)
            }
        }
    }

    // MARK: - Appearance

    @IBInspectable open dynamic var isVertical: Bool {
        get { return orientation == .vertical }
        set { orientation = newValue ? .vertical : .horizontal }
    }

    @objc open dynamic var orientation: NSLayoutConstraint.Axis = .vertical {
        didSet {
            let oldConstraintAttribute: NSLayoutConstraint.Attribute = oldValue == .vertical ? .width : .height
            removeFirstConstraint(where: { $0.firstAttribute == oldConstraintAttribute && $0.firstItem === self && $0.secondItem == nil })
            setupOrientation()
            invalidateIntrinsicContentSize()
            repositionThumbViews()
        }
    }

    /// track color before first thumb and after last thumb. `nil` means to use the tintColor, like the rest of the track.
    @IBInspectable open dynamic var outerTrackColor: UIColor? {
        didSet {
            updateOuterTrackViews()
        }
    }

    @IBInspectable public dynamic var thumbTintColor: UIColor? {
        didSet {
            thumbViews.forEach { $0.applyTint(color: thumbTintColor) }
        }
    }

    @IBInspectable open dynamic var thumbImage: UIImage? {
        didSet {
            thumbViews.forEach { $0.image = thumbImage }
            setupTrackLayoutMargins()
            invalidateIntrinsicContentSize()
        }
    }

    /// Respond to dragging beyond thumb image (useful if the image is small)
    @IBInspectable open dynamic var thumbTouchExpansionRadius: CGFloat = 0

    @IBInspectable public dynamic var showsThumbImageShadow: Bool = true {
        didSet {
            updateThumbViewShadowVisibility()
        }
    }

    @IBInspectable open dynamic var minimumImage: UIImage? {
        get {
            return minimumView.image
        }
        set {
            minimumView.image = newValue
            minimumView.isHidden = newValue == nil
            layoutTrackEdge(
                toView: minimumView,
                edge: .bottom(in: orientation),
                superviewEdge: orientation == .vertical ? .bottomMargin : .leftMargin
            )
        }
    }

    @IBInspectable open dynamic var maximumImage: UIImage? {
        get {
            return maximumView.image
        }
        set {
            maximumView.image = newValue
            maximumView.isHidden = newValue == nil
            layoutTrackEdge(
                toView: maximumView,
                edge: .top(in: orientation),
                superviewEdge: orientation == .vertical ? .topMargin : .rightMargin
            )
        }
    }

    @IBInspectable open dynamic var trackWidth: CGFloat = 2 {
        didSet {
            let widthAttribute: NSLayoutConstraint.Attribute = orientation == .vertical ? .width : .height
            trackView.removeFirstConstraint { $0.firstAttribute == widthAttribute }
            trackView.constrain(widthAttribute, to: trackWidth)
            updateTrackViewCornerRounding()
        }
    }

    @IBInspectable public dynamic var hasRoundTrackEnds: Bool = true {
        didSet {
            updateTrackViewCornerRounding()
        }
    }

    /// when thumb value is minimum or maximum, align it's center with the track end instead of its edge.
    @IBInspectable public dynamic var centerThumbOnTrackEnd: Bool = false {
        didSet {
            setupTrackLayoutMargins()
        }
    }


    // MARK: - Private vars

    private(set) var thumbsCustomAccessibility: Bool = false
    private(set) var customAccessibilityPrefixes: [String] = []

    // MARK: - Subviews

    @objc open var thumbViews: [UIImageView] = []
    @objc open var valueLabels: [UITextField] = [] // UILabels are a pain to layout, text fields look nice as-is.
    @objc open var trackView = UIView()
    @objc open var snapViews: [UIImageView] = []
    @objc open var outerTrackViews: [UIView] = []
    @objc open var minimumView = UIImageView()
    @objc open var maximumView = UIImageView()

    // MARK: - Internals

    let slideView = UIView()
    let panGestureView = UIView()
    let margin: CGFloat = 32
    var isSettingValue = false
    lazy var defaultThumbImage: UIImage? = .circle()
    var selectionFeedbackGenerator: UISelectionFeedbackGenerator?

    // MARK: - Overrides

    override open func tintColorDidChange() {
        let thumbTint = thumbViews.map { $0.tintColor } // different thumbs may have different tints
        super.tintColorDidChange()
        let actualColor = actualTintColor
        trackView.backgroundColor = actualColor
        minimumView.tintColor = actualColor
        maximumView.tintColor = actualColor
        for (thumbView, tint) in zip(thumbViews, thumbTint) {
            thumbView.tintColor = tint
        }
    }

    override open var intrinsicContentSize: CGSize {
        let thumbSize = (thumbImage ?? defaultThumbImage)?.size ?? CGSize(width: margin, height: margin)
        switch orientation {
        case .vertical:
            return CGSize(width: thumbSize.width + margin, height: UIView.noIntrinsicMetric)
        default:
            return CGSize(width: UIView.noIntrinsicMetric, height: thumbSize.height + margin)
        }
    }

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || alpha == 0 { return nil }
        if clipsToBounds { return super.hitTest(point, with: event) }
        return panGestureView.hitTest(panGestureView.convert(point, from: self), with: event)
    }

    // swiftlint:disable:next block_based_kvo
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NumberFormatter === valueLabelFormatter {
            updateAllValueLabels()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        if #available(iOS 11.0, *) {
            valueLabelFormatter.removeObserverForAllProperties(observer: self)
        }
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        // make visual editing easier
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor

        // evenly distribute thumbs
        let oldThumbCount = thumbCount
        thumbCount = 0
        thumbCount = oldThumbCount
    }

    open func setupThumbsCustomAccessibility(prefixes: [String]) {
        isAccessibilityElement = false
        thumbsCustomAccessibility = true
        customAccessibilityPrefixes = prefixes
    }
}
