//
//  BindableVar.swift
//  LittleBirdie
//
//  Created by Manish Kumar on 2021-05-24.
//
/// Original idea from: https://www.raywenderlich.com/6733535-ios-mvvm-tutorial-refactoring-from-mvc

import Foundation

final class BindableVar<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?

    public var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    public func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
