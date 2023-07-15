//
//  MultiSlider+Internal.swift
//  MultiSlider
//
//  Created by Yonat Sharon on 21/06/2019.
//

import UIKit

extension MultiSlider {
    func setup() {
        trackView.backgroundColor = actualTintColor
        updateTrackViewCornerRounding()
        slideView.layoutMargins = .zero
        setupOrientation()
        setupPanGesture()

        isAccessibilityElement = true
        accessibilityIdentifier = "multi_slider"
        accessibilityLabel = "slider"
        accessibilityTraits = [.adjustable]

        minimumView.isHidden = true
        maximumView.isHidden = true

        if #available(iOS 11.0, *) {
            valueLabelFormatter.addObserverForAllProperties(observer: self)
        }
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

    func setupOrientation() {
        trackView.removeFromSuperview()
        trackView.removeConstraints(trackView.constraints)
        slideView.removeFromSuperview()
        minimumView.removeFromSuperview()
        maximumView.removeFromSuperview()
        switch orientation {
        case .vertical:
            let centerAttribute: NSLayoutConstraint.Attribute
            if #available(iOS 12, *) {
                centerAttribute = .centerX // iOS 12 doesn't like .topMargin, .rightMargin
            } else {
                centerAttribute = .centerXWithinMargins
            }
            addConstrainedSubview(trackView, constrain: .top, .bottom, centerAttribute)
            trackView.constrain(.width, to: trackWidth)
            trackView.addConstrainedSubview(slideView, constrain: .left, .right)
            constrainVerticalTrackViewToLayoutMargins()
            addConstrainedSubview(minimumView, constrain: .bottomMargin, centerAttribute)
            addConstrainedSubview(maximumView, constrain: .topMargin, centerAttribute)
        default:
            let centerAttribute: NSLayoutConstraint.Attribute
            if #available(iOS 12, *) {
                centerAttribute = .centerY // iOS 12 doesn't like .leftMargin, .rightMargin
            } else {
                centerAttribute = .centerYWithinMargins
            }
            addConstrainedSubview(trackView, constrain: .left, .right, centerAttribute)
            trackView.constrain(.height, to: trackWidth)
            trackView.addConstrainedSubview(slideView, constrain: .top, .bottom)
            constrainHorizontalTrackViewToLayoutMargins()
            addConstrainedSubview(minimumView, constrain: .leftMargin, centerAttribute)
            addConstrainedSubview(maximumView, constrain: .rightMargin, centerAttribute)
        }
        setupTrackLayoutMargins()
    }

    func setupTrackLayoutMargins() {
        let thumbSize = (thumbImage ?? defaultThumbImage)?.size ?? CGSize(width: 2, height: 2)
        let thumbDiameter = orientation == .vertical ? thumbSize.height : thumbSize.width
        let margin = (centerThumbOnTrackEnd || nil != snapImage)
            ? 0
            : thumbDiameter / 2 - 1 // 1 pixel for semi-transparent boundary
        if orientation == .vertical {
            trackView.layoutMargins = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
            constrainVerticalTrackViewToLayoutMargins()
            constrain(.width, to: max(thumbSize.width, trackWidth), relation: .greaterThanOrEqual)
        } else {
            trackView.layoutMargins = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
            constrainHorizontalTrackViewToLayoutMargins()
            constrain(.height, to: max(thumbSize.height, trackWidth), relation: .greaterThanOrEqual)
        }
    }

    /// workaround to a problem in iOS 12-13, of constraining to `leftMargin` and `rightMargin`.
    func constrainHorizontalTrackViewToLayoutMargins() {
        trackView.constrain(slideView, at: .left, diff: trackView.layoutMargins.left)
        trackView.constrain(slideView, at: .right, diff: -trackView.layoutMargins.right)
    }

    /// workaround to a problem in iOS 12-13, of constraining to `topMargin` and `bottomMargin`.
    func constrainVerticalTrackViewToLayoutMargins() {
        trackView.constrain(slideView, at: .top, diff: trackView.layoutMargins.top)
        trackView.constrain(slideView, at: .bottom, diff: -trackView.layoutMargins.bottom)
    }

    func repositionThumbViews() {
        thumbViews.forEach { $0.removeFromSuperview() }
        thumbViews = []
        valueLabels.forEach { $0.removeFromSuperview() }
        valueLabels = []
        adjustThumbCountToValueCount()
    }

    func adjustThumbCountToValueCount() {
        guard value.count != thumbViews.count else { return }
        thumbViews.removeAllViews()
        valueLabels.removeAllViews()
        for _ in value {
            addThumbView()
        }
        updateOuterTrackViews()
    }

    func updateOuterTrackViews() {
        outerTrackViews.removeAllViews()
        outerTrackViews.removeAll()
        guard nil != outerTrackColor else { return }
        guard let lastThumb = thumbViews.last else { return }
        outerTrackViews = [outerTrackView(constraining: .bottom(in: orientation), to: lastThumb)]
        guard let firstThumb = thumbViews.first, firstThumb != lastThumb else { return }
        outerTrackViews += [outerTrackView(constraining: .top(in: orientation), to: firstThumb)]
    }

    private func outerTrackView(constraining: NSLayoutConstraint.Attribute, to thumbView: UIView) -> UIView {
        let view = UIView()
        view.backgroundColor = outerTrackColor
        trackView.addConstrainedSubview(view, constrain: .top, .bottom, .left, .right)
        trackView.removeFirstConstraint { $0.firstItem === view && $0.firstAttribute == constraining }
        trackView.constrain(view, at: constraining, to: thumbView, at: .center(in: orientation))
        trackView.sendSubviewToBack(view)

        view.layer.cornerRadius = trackView.layer.cornerRadius
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = .direction(constraining.opposite)
        }

        return view
    }

    func addSnapView(at snapValue: CGFloat) {
        let snapView = UIImageView(image: snapImage)
        snapView.tintColor = actualTintColor
        snapViews.append(snapView)
        slideView.addConstrainedSubview(snapView, constrain: NSLayoutConstraint.Attribute.center(in: orientation).perpendicularCenter)
        slideView.sendSubviewToBack(snapView)
        position(marker: snapView, at: snapValue)
    }

    private func addThumbView() {
        let i = thumbViews.count
        let thumbView = UIImageView(image: thumbImage ?? defaultThumbImage)
        thumbView.applyTint(color: thumbTintColor)
        thumbView.addShadow()
        thumbViews.append(thumbView)
        slideView.addConstrainedSubview(thumbView, constrain: NSLayoutConstraint.Attribute.center(in: orientation).perpendicularCenter)
        positionThumbView(i)
        thumbView.blur(disabledThumbIndices.contains(i))
        addValueLabel(i)
        updateThumbViewShadowVisibility()
    }

    func updateThumbViewShadowVisibility() {
        thumbViews.forEach {
            $0.layer.shadowOpacity = showsThumbImageShadow ? 0.25 : 0
        }
    }

    func addValueLabel(_ i: Int) {
        guard valueLabelPosition != .notAnAttribute else { return }
        let valueLabel = UITextField()
        valueLabel.borderStyle = .none
        slideView.addConstrainedSubview(valueLabel)
        valueLabel.textColor = valueLabelColor ?? valueLabel.textColor
        valueLabel.font = valueLabelFont ?? UIFont.preferredFont(forTextStyle: .footnote)
        if #available(iOS 10.0, *) {
            valueLabel.adjustsFontForContentSizeCategory = true
        }
        let thumbView = thumbViews[i]
        slideView.constrain(valueLabel, at: valueLabelPosition.perpendicularCenter, to: thumbView)
        let position = valueLabelAlternatePosition && (i % 2) == 0
            ? valueLabelPosition.opposite
            : valueLabelPosition
        slideView.constrain(
            valueLabel, at: position.opposite,
            to: thumbView, at: position,
            diff: -position.inwardSign * thumbView.diagonalSize / 4
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
        valueLabels[i].text = valueLabelTextForThumb?(i, labelValue)
            ?? valueLabelFormatter.string(from: NSNumber(value: Double(labelValue)))
    }

    func updateAllValueLabels() {
        for i in 0 ..< valueLabels.count {
            updateValueLabel(i)
        }
    }

    func updateValueLabelPosition() {
        valueLabels.removeAllViews()
        if valueLabelPosition != .notAnAttribute {
            for i in 0 ..< thumbViews.count {
                addValueLabel(i)
            }
        }
    }

    func updateValueCount(_ count: Int) {
        guard count != value.count else { return }
        isSettingValue = true
        defer { isSettingValue = false }

        if value.count < count {
            let appendCount = count - value.count
            value += snapValues.isEmpty
                ? value.distributedNewValues(count: appendCount, min: minimumValue, max: maximumValue)
                : value.distributedNewValues(count: appendCount, allowedValues: snapValues)
            value.sort()
        }
        if value.count > count { // don't add "else", since prev calc may add too many values in some cases
            value.removeLast(value.count - count)
        }
    }

    func adjustValuesToStepAndLimits() {
        var adjusted = value.sorted()
        for i in 0 ..< adjusted.count {
            adjusted[i] = snap.snap(value: adjusted[i])
        }

        isSettingValue = true
        value = adjusted
        isSettingValue = false

        for i in 0 ..< value.count {
            positionThumbView(i)
        }
    }

    func positionThumbView(_ i: Int) {
        position(marker: thumbViews[i], at: value[i])
    }

    private func position(marker: UIView, at value: CGFloat) {
        guard let containerView = marker.superview else { return }
        containerView.removeFirstConstraint { $0.firstItem === marker && $0.firstAttribute == .center(in: orientation) }
        let relativeDistanceToMax = (maximumValue - value) / (maximumValue - minimumValue)
        if orientation == .horizontal {
            if relativeDistanceToMax < 1 {
                containerView.constrain(marker, at: .centerX, to: containerView, at: .right, ratio: CGFloat(1 - relativeDistanceToMax))
            } else {
                containerView.constrain(marker, at: .centerX, to: containerView, at: .left)
            }
        } else { // vertical orientation
            if relativeDistanceToMax.isNormal {
                containerView.constrain(marker, at: .centerY, to: containerView, at: .bottom, ratio: CGFloat(relativeDistanceToMax))
            } else {
                containerView.constrain(marker, at: .centerY, to: containerView, at: .top)
            }
        }
        UIView.animate(withDuration: 0.1) {
            containerView.updateConstraintsIfNeeded()
        }
    }

    func changePositionConstraint(for subview: UIView?, to constant: CGFloat) {
        guard let constraint = subview?.superview?.constraints.first(where: { $0.firstItem === subview && $0.firstAttribute == .center(in: orientation) }) else { return }
        constraint.constant = constant * constraint.secondAttribute.inwardSign
    }

    func layoutTrackEdge(toView: UIImageView, edge: NSLayoutConstraint.Attribute, superviewEdge: NSLayoutConstraint.Attribute) {
        removeFirstConstraint { $0.firstItem === self.trackView && ($0.firstAttribute == edge || $0.firstAttribute == superviewEdge) }
        if nil != toView.image {
            constrain(trackView, at: edge, to: toView, at: edge.opposite, diff: edge.inwardSign * 8)
        } else {
            constrain(trackView, at: edge, to: self, at: superviewEdge)
        }
    }

    func updateTrackViewCornerRounding() {
        trackView.layer.cornerRadius = hasRoundTrackEnds ? trackWidth / 2 : 1
        outerTrackViews.forEach { $0.layer.cornerRadius = trackView.layer.cornerRadius }
    }
}
