//
//  MainManager.swift
//  evInfra
//
//  Created by youjin kim on 2022/10/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import RxSwift

enum MainAction {
    case hideMenu(Bool)
}

protocol MainManagerProtocol {
    var action: PublishSubject<MainAction> { get }
    func hideMenu(_ isHideMenu: Bool) -> Observable<Bool>
}

class MainManager: MainManagerProtocol {
     let action = PublishSubject<MainAction>()
    
    func hideMenu(_ isHideMenu: Bool) -> Observable<Bool> {
        action.onNext(.hideMenu(isHideMenu))
        return .just(isHideMenu)
    }
}
