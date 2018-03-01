//
//  ViewController.swift
//  MultiSliderDemo
//
//  Created by Yonat Sharon on 17.11.2016.
//  Copyright © 2016 Yonat Sharon. All rights reserved.
//

import UIKit
import MultiSlider

class ViewController: UIViewController {

    @IBOutlet weak var multiSlider: MultiSlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        multiSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        multiSlider.disabledThumbIndices = [3]

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
        horizontalMultiSlider.thumbCount = 3
        horizontalMultiSlider.valueLabelPosition = .top
        horizontalMultiSlider.tintColor = .purple
        horizontalMultiSlider.trackWidth = 32
        horizontalMultiSlider.showsThumbImageShadow = false
        view.addConstrainedSubview(horizontalMultiSlider, constrain: .leftMargin, .rightMargin, .bottomMargin)
}

    @objc func sliderChanged(_ slider: MultiSlider) {
        print("\(slider.value)")
    }

}

