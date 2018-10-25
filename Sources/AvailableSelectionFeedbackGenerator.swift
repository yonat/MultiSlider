//
//  AvailableSelectionFeedbackGenerator.swift
//  MultiSlider
//
//  Created by Yonat Sharon on 25.10.2018.
//

import Foundation

/// Wrapper for UISelectionFeedbackGenerator that compiles on iOS 9
class AvailableSelectionFeedbackGenerator {
    func start() {
        if #available(iOS 10.0, *) {
            if nil == _selectionFeedbackGenerator {
                _selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            }
            selectionFeedbackGenerator.prepare()
        }
    }

    func generateFeedback() {
        if #available(iOS 10.0, *) {
            selectionFeedbackGenerator.selectionChanged()
        }
    }

    func end() {
        _selectionFeedbackGenerator = nil
    }

    @available(iOS 10.0, *)
    var selectionFeedbackGenerator: UISelectionFeedbackGenerator {
        if nil == _selectionFeedbackGenerator {
            start()
        }
        // swiftlint:disable force_cast force_unwrapping
        return _selectionFeedbackGenerator! as! UISelectionFeedbackGenerator
        // swiftlint:enable force_cast force_unwrapping
    }

    private var _selectionFeedbackGenerator: Any?
}
