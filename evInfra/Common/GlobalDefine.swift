//
//  GlobalDefine.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//
import RxSwift

import RxSwift

internal final class GlobalDefine: NSObject {
    internal static var shared = GlobalDefine()
    
    internal weak var mainNavi: AppNavigationController?
    internal var isUseAllBerry = PublishSubject<Bool>()
    internal weak var mainViewcon: MainViewController?
    internal var sharedChargerIdFromDynamicLink: String?
    internal var tempDeepLink: String = ""
}



