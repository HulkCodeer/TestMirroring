//
//  Observable+Operators.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

protocol OptionalType {
    associatedtype Wrapped

    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    var value: Wrapped? {
        self
    }
}

extension Observable where Element: OptionalType {
    func filterNil() -> Observable<Element.Wrapped> {
        flatMap { element -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }

    func filterNilKeepOptional() -> Observable<Element> {
        self.filter { element -> Bool in
            element.value != nil
        }
    }

    func replaceNil(with nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
        flatMap { element -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .just(nilValue)
            }
        }
    }
}

protocol BooleanType {
    var boolValue: Bool { get }
}

extension Bool: BooleanType {
    var boolValue: Bool { self }
}

// Maps true to false and vice versa
extension Observable where Element: BooleanType {
    func not() -> Observable<Bool> {
        self.map { input in
            !input.boolValue
        }
    }
}

extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        filter { selfE -> Bool in
            value != selfE
        }
    }
}

extension ObservableType {
    func catchErrorJustComplete() -> Observable<Element> {
        catchError { _ in
            Observable.empty()
        }
    }

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { error in
            assertionFailure("Error \(error)")
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        map { _ in }
    }
}
