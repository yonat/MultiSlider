//
//  MultiSlider+Drag.swift
//  MultiSlider
//
//  Created by Yonat Sharon on 25.10.2018.
//

import UIKit

extension MultiSlider: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = otherGestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = panGesture.velocity(in: self)
        let panOrientation: NSLayoutConstraint.Axis = abs(velocity.y) > abs(velocity.x) ? .vertical : .horizontal
        return panOrientation != orientation
    }

    @objc open func didDrag(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            // determine thumb to drag
            let location = panGesture.location(in: slideView)
            draggedThumbIndex = closestThumb(point: location)
        case .ended, .cancelled, .failed:
            sendActions(for: .touchUpInside) // no bounds check for now (.touchUpInside vs .touchUpOutside)
            if !isContinuous { sendActions(for: [.valueChanged, .primaryActionTriggered]) }
        default:
            break
        }
        guard draggedThumbIndex >= 0 else { return }

        let slideViewLength = slideView.bounds.size(in: orientation)
        var targetPosition = panGesture.location(in: slideView).coordinate(in: orientation)

        // don't cross prev/next thumb and total range
        targetPosition = boundedDraggedThumbPosition(targetPosition: targetPosition)

        // change corresponding value
        updateDraggedThumbValue(relativeValue: targetPosition / slideViewLength)

        UIView.animate(withDuration: 0.1) {
            self.updateDraggedThumbPositionAndLabel()
            self.layoutIfNeeded()
        }
    }

    /// adjusted position that doesn't cross prev/next thumb and total range
    private func boundedDraggedThumbPosition(targetPosition: CGFloat) -> CGFloat {
        var delta: CGFloat = 0 // distance between thumbs in view coordinates
        if distanceBetweenThumbs < 0 {
            delta = thumbViews[draggedThumbIndex].frame.size(in: orientation) / 2
        } else if distanceBetweenThumbs > 0 && distanceBetweenThumbs < maximumValue - minimumValue {
            delta = (distanceBetweenThumbs / (maximumValue - minimumValue)) * slideView.bounds.size(in: orientation)
        }
        if orientation == .horizontal { delta = -delta }
        let bottomLimit = draggedThumbIndex > 0
            ? thumbViews[draggedThumbIndex - 1].center.coordinate(in: orientation) - delta
            : slideView.bounds.bottom(in: orientation)
        let topLimit = draggedThumbIndex < thumbViews.count - 1
            ? thumbViews[draggedThumbIndex + 1].center.coordinate(in: orientation) + delta
            : slideView.bounds.top(in: orientation)
        if orientation == .vertical {
            return min(bottomLimit, max(targetPosition, topLimit))
        } else {
            return max(bottomLimit, min(targetPosition, topLimit))
        }
    }

    private func updateDraggedThumbValue(relativeValue: CGFloat) {
        var newValue = relativeValue * (maximumValue - minimumValue)
        if orientation == .vertical {
            newValue = maximumValue - newValue
        } else {
            newValue += minimumValue
        }
        newValue = snap.snap(value: newValue)
        guard newValue != value[draggedThumbIndex] else { return }
        isSettingValue = true
        value[draggedThumbIndex] = newValue
        isSettingValue = false
        if snap != .never || relativeValue == 0 || relativeValue == 1 {
            selectionFeedbackGenerator?.selectionChanged()
        }
        if isContinuous { sendActions(for: [.valueChanged, .primaryActionTriggered]) }
    }

    private func updateDraggedThumbPositionAndLabel() {
        positionThumbView(draggedThumbIndex)
        if draggedThumbIndex < valueLabels.count {
            updateValueLabel(draggedThumbIndex)
            if isValueLabelRelative && draggedThumbIndex + 1 < valueLabels.count {
                updateValueLabel(draggedThumbIndex + 1)
            }
        }
        UIAccessibility.post(notification: .announcement, argument: valueLabelText(draggedThumbIndex, labelValue: value[draggedThumbIndex]))
    }

    private func closestThumb(point: CGPoint) -> Int {
        var closest = -1
        var minimumDistance = CGFloat.greatestFiniteMagnitude
        let pointCoordinate = point.coordinate(in: orientation)
        for i in 0 ..< thumbViews.count {
            guard !disabledThumbIndices.contains(i) else { continue }
            let thumbCoordinate = thumbViews[i].center.coordinate(in: orientation)
            let distance = abs(pointCoordinate - thumbCoordinate)
            if distance > minimumDistance { break }
            if i > 0 && closest == i - 1 && thumbViews[i].center == thumbViews[i - 1].center { // overlapping thumbs
                let greaterSign: CGFloat = orientation == .vertical ? -1 : 1
                if greaterSign * thumbCoordinate < greaterSign * pointCoordinate {
                    closest = i
                }
                break
            }
            minimumDistance = distance
            if distance < thumbViews[i].diagonalSize + thumbTouchExpansionRadius {
                closest = i
            }
        }
        return closest
    }
}
