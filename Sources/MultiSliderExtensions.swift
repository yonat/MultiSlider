//
//  MultiSliderExtensions.swift
//  MultiSlider
//
//  Created by Yonat Sharon on 20.05.2018.
//

import UIKit

extension CGFloat {
    func truncated(_ step: CGFloat) -> CGFloat {
        return step.isNormal ? self - remainder(dividingBy: step) : self
    }

    func rounded(_ step: CGFloat) -> CGFloat {
        guard step.isNormal && isNormal else { return self }
        let remainder = self.remainder(dividingBy: step)
        let truncated = self - remainder
        return remainder * 2 < step ? truncated : truncated + step
    }
}

extension CGPoint {
    func distanceTo(_ point: CGPoint) -> CGFloat {
        let (dx, dy) = (x - point.x, y - point.y)
        return hypot(dx, dy)
    }

    func coordinate(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return y
        case .horizontal:
            return x
        }
    }
}

extension CGRect {
    func size(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return height
        case .horizontal:
            return width
        }
    }

    func bottom(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return maxY
        case .horizontal:
            return minX
        }
    }

    func top(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return minY
        case .horizontal:
            return maxX
        }
    }
}

extension UIView {
    var diagonalSize: CGFloat { return hypot(frame.width, frame.height) }

    var actualTintColor: UIColor {
        var tintedView: UIView? = self
        while let currentView = tintedView, nil == currentView.tintColor {
            tintedView = currentView.superview
        }
        return tintedView?.tintColor ?? .blue
    }

    func removeFirstConstraint(where: (_: NSLayoutConstraint) -> Bool) {
        if let constrainIndex = constraints.index(where: `where`) {
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
    mutating func removeViewsStartingAt(_ index: Int) {
        guard index >= 0 && index < count else { return }
        self[index ..< count].forEach { $0.removeFromSuperview() }
        removeLast(count - index)
    }
}

extension UIImageView {
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

    static var blurViewTag: Int { return 898_989 }
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
        case .horizontal:
            return .centerX
        }
    }
}

extension UIImage {
    static func circle(diameter: CGFloat, width: CGFloat = 1, color: UIColor? = nil, fill: UIColor? = nil) -> UIImage? {
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
