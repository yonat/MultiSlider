//
//  ViewController.swift
//  swiftlint:disable numbers_smell
//
//  Created by Yonat Sharon on 17.11.2016.
//  Copyright © 2016 Yonat Sharon. All rights reserved.
//

import MultiSlider
import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

class ViewController: UIViewController {
    @IBOutlet var multiSlider: MultiSlider!
    @IBOutlet var showSwiftUIButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        multiSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
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
        horizontalMultiSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        view.addConstrainedSubview(horizontalMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin)
        view.layoutMargins = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)

        multiSlider.keepsDistanceBetweenThumbs = false
        horizontalMultiSlider.keepsDistanceBetweenThumbs = false
        horizontalMultiSlider.valueLabelFormatter.positiveSuffix = " 𝞵s"
        horizontalMultiSlider.valueLabelColor = .purple
        horizontalMultiSlider.valueLabelFont = UIFont.italicSystemFont(ofSize: 18)

        if #available(iOS 13.0, *) {
            horizontalMultiSlider.minimumImage = UIImage(systemName: "scissors")
            horizontalMultiSlider.maximumImage = UIImage(systemName: "paperplane.fill")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            showSwiftUIButton.isHidden = false
            showSwiftUIButton.layer.borderWidth = 1
            showSwiftUIButton.layer.cornerRadius = showSwiftUIButton.frame.height / 2
            showSwiftUIButton.layer.borderColor = view.actualTintColor.cgColor
        }
    }

    @objc func sliderChanged(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
    }

    @IBAction func showSwiftUIDemo() {
        #if canImport(SwiftUI)
        if #available(iOS 13.0, *) {
            present(UIHostingController(rootView: MultiValueSliderDemo()), animated: true)
        }
        #endif
    }
}
