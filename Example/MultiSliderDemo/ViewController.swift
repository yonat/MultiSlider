//
//  ViewController.swift
//  swiftlint:disable numbers_smell
//
//  Created by Yonat Sharon on 17.11.2016.
//  Copyright © 2016 Yonat Sharon. All rights reserved.
//

import MultiSlider
import UIKit

class ViewController: UIViewController {
    @IBOutlet var multiSlider: MultiSlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        multiSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        multiSlider.disabledThumbIndices = [3]

        if #available(iOS 13.0, *) {
            multiSlider.minimumImage = UIImage(systemName: "moon.fill")
            multiSlider.maximumImage = UIImage(systemName: "sun.max.fill")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.multiSlider.value = [0.4, 2.8]
            self.multiSlider.valueLabelPosition = .top
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.multiSlider.thumbCount = 5
            self.multiSlider.valueLabelPosition = .right
            self.multiSlider.isValueLabelRelative = true
        }

        let horizontalMultiSlider = MultiSlider()
        horizontalMultiSlider.orientation = .horizontal
        horizontalMultiSlider.minimumValue = 10 / 4
        horizontalMultiSlider.maximumValue = 10 / 3
        horizontalMultiSlider.outerTrackColor = .gray
        horizontalMultiSlider.value = [2.718, 3.14]
        horizontalMultiSlider.valueLabelPosition = .top
        horizontalMultiSlider.tintColor = .purple
        horizontalMultiSlider.trackWidth = 32
        horizontalMultiSlider.showsThumbImageShadow = false
        view.addConstrainedSubview(horizontalMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin)
        view.layoutMargins = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)

        multiSlider.keepsDistanceBetweenThumbs = false
        horizontalMultiSlider.keepsDistanceBetweenThumbs = false
        horizontalMultiSlider.valueLabelFormatter.positiveSuffix = " 𝞵s"

        if #available(iOS 13.0, *) {
            horizontalMultiSlider.minimumImage = UIImage(systemName: "scissors")
            horizontalMultiSlider.maximumImage = UIImage(systemName: "paperplane.fill")
            horizontalMultiSlider.thumbViews[0].image = UIImage(systemName: "arrow.up.doc.fill")
            horizontalMultiSlider.thumbViews[1].image = UIImage(systemName: "personalhotspot")
        }

        addTimeSlider()
        configureAgeSlider()
    }

    @objc func sliderChanged(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
    }

    private func addTimeSlider() {
        let timeSliderContainer = view!
        let timeSlider = MultiSlider()
        timeSlider.frame = CGRect(x: 16, y: 60, width: UIScreen.main.bounds.width - 32, height: 60)
        timeSlider.minimumValue = 00.00 // default is 0.0
        timeSlider.maximumValue = 23.5 // default is 1.0
        timeSlider.snapStepSize = 0.5
        timeSlider.value = [00.00, 23.5]
        timeSlider.thumbCount = 2
        timeSlider.outerTrackColor = .cyan // outside of first and last thumbs
        timeSlider.orientation = .horizontal // default is .vertical
        timeSlider.tintColor = .darkGray // color of track
        timeSlider.trackWidth = 6
        timeSlider.hasRoundTrackEnds = true
        timeSlider.valueLabelPosition = .top
        timeSlider.showsThumbImageShadow = true
        timeSlider.keepsDistanceBetweenThumbs = true
        timeSlider.distanceBetweenThumbs = 5

        timeSliderContainer.addSubview(timeSlider)
    }

    private func configureAgeSlider() {
        let ageSlider = MultiSlider()
        ageSlider.minimumValue = 18
        ageSlider.maximumValue = 30

        let age: CGFloat = 50
        let lowValue = max(ageSlider.minimumValue, age - 8)
        let highValue = min(ageSlider.maximumValue, age + 8)
        ageSlider.value = [lowValue, highValue]

        ageSlider.orientation = .horizontal
        ageSlider.tintColor = .red
        ageSlider.trackWidth = 3
        ageSlider.showsThumbImageShadow = false
        ageSlider.addTarget(self, action: #selector(ageSliderChanged(_:)), for: .valueChanged)
        view.addConstrainedSubview(ageSlider, constrain: .leftMargin, .rightMargin)
        view.constrain(ageSlider, at: .top, to: multiSlider, at: .bottom, diff: 16)

        // *** test problem here:
        ageSlider.valueLabelPosition = .top
        ageSlider.distanceBetweenThumbs = 4
    }

    @objc func ageSliderChanged(_ ageSlider: MultiSlider) {
        print("thumb \(ageSlider.draggedThumbIndex) moved")
        print("now thumbs are at \(ageSlider.value)")
        print("Range slider value changed: \(ageSlider.value)")
    }
}
