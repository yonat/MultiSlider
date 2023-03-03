//
//  MultiSliderExtensions.swift
//  MultiSlider
//
//  Created by Yonat Sharon on 20.05.2018.
//

import SweeterSwift
import UIKit

extension MultiSlider.Snap {
    func snap(value: CGFloat) -> CGFloat {
        switch self {
        case .never:
            return value
        case let .stepSize(stepSize):
            guard stepSize.isNormal && value.isNormal else { return value }
            return (value / stepSize).rounded() * stepSize
        case let .values(values):
            return values.closest(to: value)
        }
    }
}

extension Array where Element: SignedNumeric & Comparable {
    func closest(to number: Element) -> Element {
        guard !isEmpty else { return number }
        return self.min { abs($0 - number) < abs($1 - number) }!
    }
}

extension Array where Element: SignedNumeric & Comparable & Hashable {
    /// Distribute new `count` values evenly among `allowedValues`, skipping sender's values if possible.
    func distributedNewValues(count newValuesCount: Int, allowedValues: Self = []) -> Self {
        guard allowedValues.count > 1 else { return self }
        guard newValuesCount > 0 else { return [] }

        var ret: Self = []
        var availableSpots = Set(allowedValues).subtracting(self).sorted()
        var needingSpotsCount = newValuesCount

        while availableSpots.count <= needingSpotsCount { // fill all spots
            ret += availableSpots
            needingSpotsCount -= availableSpots.count
            availableSpots = allowedValues
        }

        if needingSpotsCount > 1 { // distribute evenly over spotsToFill
            let spotsToSkip = Double(availableSpots.count - 1) / Double(needingSpotsCount - 1)
            for i in 0 ..< needingSpotsCount {
                let spotIndex = (Double(i) * spotsToSkip).rounded()
                ret.append(availableSpots[Int(spotIndex)])
            }
        } else if needingSpotsCount == 1 {
            let spotIndex = availableSpots.count / 2
            ret.append(availableSpots[spotIndex])
        }

        return ret.sorted()
    }
}

extension Array where Element: FloatingPoint {
    /// Distribute new `count` values evenly between sender's values and `max`.
    func distributedNewValues(count newValuesCount: Int, min: Element, max: Element) -> Self {
        guard newValuesCount > 0, min < max else { return [] }

        let step: Element
        if let last = last {
            step = (max - last) / Element(newValuesCount)
        } else {
            if newValuesCount == 1 {
                return [(max + min) / 2]
            }
            step = (max - min) / Element(newValuesCount - 1)
        }
        return sequence(first: max, next: { $0 - step })
            .prefix(newValuesCount)
            .reversed()
    }
}

extension CGPoint {
    func coordinate(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return y
        default:
            return x
        }
    }
}

extension CGRect {
    func size(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return height
        default:
            return width
        }
    }

    func bottom(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return maxY
        default:
            return minX
        }
    }

    func top(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return minY
        default:
            return maxX
        }
    }
}

extension UIView {
    var diagonalSize: CGFloat { return hypot(frame.width, frame.height) }

    func removeFirstConstraint(where: (_: NSLayoutConstraint) -> Bool) {
        if let constrainIndex = constraints.firstIndex(where: `where`) {
            removeConstraint(constraints[constrainIndex])
        }
    }

    func addShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 0.5
    }
}

extension Array where Element: UIView {
    mutating func removeAllViews() {
        forEach { $0.removeFromSuperview() }
        removeAll()
    }
}

extension UIImageView {
    func applyTint(color: UIColor?) {
        image = image?.withRenderingMode(nil == color ? .alwaysOriginal : .alwaysTemplate)
        tintColor = color
    }

    func blur(_ on: Bool) {
        if on {
            guard nil == viewWithTag(UIImageView.blurViewTag) else { return }
            let blurImage = image?.withRenderingMode(.alwaysTemplate)
            let blurView = UIImageView(image: blurImage)
            blurView.tag = UIImageView.blurViewTag
            blurView.tintColor = .white
            blurView.alpha = 0.5
            addConstrainedSubview(blurView, constrain: .top, .bottom, .left, .right)
            layer.shadowOpacity /= 2
        } else {
            guard let blurView = viewWithTag(UIImageView.blurViewTag) else { return }
            blurView.removeFromSuperview()
            layer.shadowOpacity *= 2
        }
    }

    static var blurViewTag: Int { return 898_989 } // swiftlint:disable:this numbers_smell
}

extension NSLayoutConstraint.Attribute {
    var opposite: NSLayoutConstraint.Attribute {
        switch self {
        case .left: return .right
        case .right: return .left
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        case .leftMargin: return .rightMargin
        case .rightMargin: return .leftMargin
        case .topMargin: return .bottomMargin
        case .bottomMargin: return .topMargin
        case .leadingMargin: return .trailingMargin
        case .trailingMargin: return .leadingMargin
        default: return self
        }
    }

    var inwardSign: CGFloat {
        switch self {
        case .top, .topMargin: return 1
        case .bottom, .bottomMargin: return -1
        case .left, .leading, .leftMargin, .leadingMargin: return 1
        case .right, .trailing, .rightMargin, .trailingMargin: return -1
        default: return 1
        }
    }

    var perpendicularCenter: NSLayoutConstraint.Attribute {
        switch self {
        case .left, .leading, .leftMargin, .leadingMargin, .right, .trailing, .rightMargin, .trailingMargin, .centerX:
            return .centerY
        default:
            return .centerX
        }
    }

    static func center(in axis: NSLayoutConstraint.Axis) -> NSLayoutConstraint.Attribute {
        switch axis {
        case .vertical:
            return .centerY
        default:
            return .centerX
        }
    }

    static func top(in axis: NSLayoutConstraint.Axis) -> NSLayoutConstraint.Attribute {
        switch axis {
        case .vertical:
            return .top
        default:
            return .right
        }
    }

    static func bottom(in axis: NSLayoutConstraint.Axis) -> NSLayoutConstraint.Attribute {
        switch axis {
        case .vertical:
            return .bottom
        default:
            return .left
        }
    }
}

extension CACornerMask {
    static func direction(_ attribute: NSLayoutConstraint.Attribute) -> CACornerMask {
        switch attribute {
        case .bottom:
            return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .top:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .leading, .left:
            return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .trailing, .right:
            return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        default:
            return []
        }
    }
}

extension UIImage {
    static func circle(diameter: CGFloat = 29, width: CGFloat = 0.5, color: UIColor? = UIColor.lightGray.withAlphaComponent(0.5), fill: UIColor? = .white) -> UIImage? {
        let circleLayer = CAShapeLayer()
        circleLayer.fillColor = fill?.cgColor
        circleLayer.strokeColor = color?.cgColor
        circleLayer.lineWidth = width
        let margin = width * 2
        let circle = UIBezierPath(ovalIn: CGRect(x: margin, y: margin, width: diameter, height: diameter))
        circleLayer.bounds = CGRect(x: 0, y: 0, width: diameter + margin * 2, height: diameter + margin * 2)
        circleLayer.path = circle.cgPath
        UIGraphicsBeginImageContextWithOptions(circleLayer.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        circleLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension NSObject {
    func addObserverForAllProperties(
        observer: NSObject,
        options: NSKeyValueObservingOptions = [],
        context: UnsafeMutableRawPointer? = nil
    ) {
        performForAllKeyPaths { keyPath in
            addObserver(observer, forKeyPath: keyPath, options: options, context: context)
        }
    }

    func removeObserverForAllProperties(
        observer: NSObject,
        context: UnsafeMutableRawPointer? = nil
    ) {
        performForAllKeyPaths { keyPath in
            removeObserver(observer, forKeyPath: keyPath, context: context)
        }
    }

    func performForAllKeyPaths(_ action: (String) -> Void) {
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(object_getClass(self), &count) else { return }
        defer { free(properties) }
        for i in 0 ..< Int(count) {
            let keyPath = String(cString: property_getName(properties[i]))
            action(keyPath)
        }
    }
}
