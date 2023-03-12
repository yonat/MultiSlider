//
//  MultiSliderDemo.swift
//
//  Copyright © 2019 Yonat Sharon. All rights reserved.
//

// swiftlint:disable numbers_smell
#if canImport(SwiftUI)

import MultiSlider
import SwiftUI

@available(iOS 13.0, *)
struct MultiValueSliderDemo: View {
    @State private var doubleValue: [CGFloat] = [1, 3]
    @State private var tripleValue: [CGFloat] = [1, 3, 5]

    var body: some View {
        VStack(alignment: .center) {
            MultiValueSlider(
                value: $doubleValue,
                maximumValue: 5,
                snapStepSize: 1,
                orientation: .horizontal,
                outerTrackColor: .lightGray
            )
            .snapImage(.init(systemName: "line.diagonal"))
            .frame(width: 320)
            .scaledToFit()

            MultiValueSlider(
                value: $tripleValue,
                maximumValue: 5,
                valueLabelPosition: .top,
                orientation: .horizontal
            )
            .accentColor(.purple)

            HStack {
                MultiValueSlider(
                    value: $doubleValue,
                    maximumValue: 5,
                    valueLabelPosition: .right,
                    orientation: .vertical,
                    valueLabelColor: .systemGreen,
                    valueLabelFont: .boldSystemFont(ofSize: 20),
                    trackWidth: 12
                )
                .snapValues([0.5, 1, 2, 3, 0.2])
                .snapImage(snapImage)
                .accentColor(.green)

                MultiValueSlider(
                    value: $tripleValue,
                    maximumValue: 5,
                    orientation: .vertical,
                    outerTrackColor: .lightGray,
                    trackWidth: 12
                )
                .thumbTintColor(.blue)
            }
        }
        .padding()
    }

    let snapImage = UIImage(
        systemName: "minus",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)
            .applying(UIImage.SymbolConfiguration(weight: .black))
    )?
        .withTintColor(.darkGray, renderingMode: .alwaysOriginal)
}

#endif
