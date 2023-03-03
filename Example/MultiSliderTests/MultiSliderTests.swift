//
//  MultiSliderTests.swift
//  MultiSliderTests
//
//  Created by Yonat Sharon on 02/03/2023.
//  Copyright © 2023 Yonat Sharon. All rights reserved.
//

@testable import MultiSlider
import XCTest

final class MultiSliderTests: XCTestCase {
    func testDistributeAllowedValues() {
        XCTAssertEqual([Int]().distributedNewValues(count: 0, allowedValues: []), [])

        XCTAssertEqual([Int]().distributedNewValues(count: 1, allowedValues: [1, 2]), [2])
        XCTAssertEqual([Int]().distributedNewValues(count: 2, allowedValues: [1, 2]), [1, 2])

        XCTAssertEqual([Int]().distributedNewValues(count: 3, allowedValues: [1, 2]), [1, 2, 2])
        XCTAssertEqual([Int]().distributedNewValues(count: 4, allowedValues: [1, 2]), [1, 1, 2, 2])

        XCTAssertEqual([Int]().distributedNewValues(count: 1, allowedValues: [1, 2, 4, 8]), [4])
        XCTAssertEqual([Int]().distributedNewValues(count: 2, allowedValues: [1, 2, 4, 8]), [1, 8])
        XCTAssertEqual([Int]().distributedNewValues(count: 3, allowedValues: [1, 2, 4, 8]), [1, 4, 8])
        XCTAssertEqual([Int]().distributedNewValues(count: 4, allowedValues: [1, 2, 4, 8]), [1, 2, 4, 8])
        XCTAssertEqual([Int]().distributedNewValues(count: 5, allowedValues: [1, 2, 4, 8]), [1, 2, 4, 4, 8])

        XCTAssertEqual([1, 4].distributedNewValues(count: 1, allowedValues: [1, 2, 4, 8]), [8])
        XCTAssertEqual([1, 4].distributedNewValues(count: 2, allowedValues: [1, 2, 4, 8]), [2, 8])
        XCTAssertEqual([1, 4].distributedNewValues(count: 3, allowedValues: [1, 2, 4, 8]), [2, 4, 8])
        XCTAssertEqual([1, 4].distributedNewValues(count: 4, allowedValues: [1, 2, 4, 8]), [1, 2, 8, 8])

        let snapValues = Array(stride(from: 0.0, through: 5.0, by: 0.25))
        XCTAssertEqual([Double]().distributedNewValues(count: 5, allowedValues: snapValues), [0, 1.25, 2.5, 3.75, 5])
    }

    func testDistributeContinuousValues() {
        XCTAssertEqual([Double]().distributedNewValues(count: 0, min: 0, max: 6), [])

        XCTAssertEqual([Double]().distributedNewValues(count: 1, min: 0, max: 6), [3])
        XCTAssertEqual([Double]().distributedNewValues(count: 2, min: 0, max: 6), [0, 6])
        XCTAssertEqual([Double]().distributedNewValues(count: 3, min: 0, max: 6), [0, 3, 6])
        XCTAssertEqual([Double]().distributedNewValues(count: 5, min: 0, max: 5), [0, 1.25, 2.5, 3.75, 5])

        XCTAssertEqual([1, 2].distributedNewValues(count: 1, min: 0, max: 6), [6])
        XCTAssertEqual([1, 2].distributedNewValues(count: 2, min: 0, max: 6), [4, 6])
        XCTAssertEqual([1, 3].distributedNewValues(count: 3, min: 0, max: 6), [4, 5, 6])
    }
}
