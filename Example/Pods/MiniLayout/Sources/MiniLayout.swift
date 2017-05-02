//
//  MiniLayout.swift
//  Minimal AutoLayout convenience layer. Program constraints succinctly.
//
//  Created by Yonat Sharon on 06.04.2015.
//  Copyright (c) 2015 Yonat Sharon. All rights reserved.
//

import UIKit

public extension UIView
{
    /// Set constant attribute. Example: constrain(.Width, to: 17)
    @discardableResult public func constrain(_ at: NSLayoutAttribute, to: CGFloat = 0, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(item: self, attribute: at, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: ratio, constant: to)
        addConstraint(constraint)
        return constraint
    }

    /// Pin subview at a specific place. Example: constrain(label, at: .Top)
    @discardableResult public func constrain(_ subview: UIView, at: NSLayoutAttribute, diff: CGFloat = 0, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(item: subview, attribute: at, relatedBy: relation, toItem: self, attribute: at, multiplier: ratio, constant: diff)
        addConstraint(constraint)
        return constraint
    }

    /// Pin two subviews to each other. Example:
    ///
    /// constrain(label, at: .Leading, to: textField)
    ///
    /// constrain(textField, at: .Top, to: label, at: .Bottom, diff: 8)
    @discardableResult public func constrain(_ subview: UIView, at: NSLayoutAttribute, to subview2: UIView, at at2: NSLayoutAttribute = .notAnAttribute, diff: CGFloat = 0, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint
    {
        let at2real = at2 == .notAnAttribute ? at : at2
        let constraint = NSLayoutConstraint(item: subview, attribute: at, relatedBy: relation, toItem: subview2, attribute: at2real, multiplier: ratio, constant: diff)
        addConstraint(constraint)
        return constraint
    }

    /// Add subview pinned to specific places. Example: addConstrainedSubview(button, constrain: .CenterX, .CenterY)
    @discardableResult public func addConstrainedSubview(_ subview: UIView, constrain: NSLayoutAttribute...) -> [NSLayoutConstraint]
    {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        return constrain.map { self.constrain(subview, at: $0) }
    }
}
