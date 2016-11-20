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
        multiSlider.addTarget(self, action: #selector(sliderChanged(_:)), forControlEvents: .ValueChanged)
        multiSlider.disabledThumbIndices = [3]

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            self.multiSlider.value = [0.4, 2.8]
            self.multiSlider.valueLabelPosition = .Left
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            self.multiSlider.thumbCount = 5
            self.multiSlider.valueLabelPosition = .Right
            self.multiSlider.isValueLabelRelative = true
        }
    }

    func sliderChanged(slider: MultiSlider) {
        print("\(slider.value)")
    }

}

