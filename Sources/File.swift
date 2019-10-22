//
//  File.swift
//  
//
//  Created by Yuriy Makarov on 22.10.2019.
//  yuri.makarow@yandex.ru

import Foundation

extension Reactive where Base: MultiSlider {
    
    public var value: ControlProperty<[CGFloat]> {
        return base.rx.controlProperty(editingEvents: .allTouchEvents, getter: { range in
            range.value
        }, setter: { range, value in
            range.value = value
        })
    }
    
}
