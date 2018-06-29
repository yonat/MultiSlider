//
//  ViewController.swift
//  MultiSliderDemo
//
//  Created by Yonat Sharon on 17.11.2016.
//  Copyright © 2016 Yonat Sharon. All rights reserved.
//

import MultiSlider
import UIKit

class ViewController: UIViewController {
    @IBOutlet var multiSlider: MultiSlider!
    @IBOutlet var valueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        multiSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        multiSlider.addTarget(self, action: #selector(sliderDragEnded(_:)), for: [.touchUpInside, .touchUpOutside])
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.updateValueLabel(text: "\(self.multiSlider.value)")
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

    @objc func sliderDragEnded(_ slider: MultiSlider) {
        updateValueLabel(text: "\(slider.value)")
    }

    func updateValueLabel(text: String) {
        valueLabel.text = text
    }
}
