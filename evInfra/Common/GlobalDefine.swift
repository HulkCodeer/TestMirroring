//
//  GlobalDefine.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import RxSwift

internal final class GlobalDefine: NSObject {
    internal static var shared = GlobalDefine()
    
    internal weak var mainNavi: UINavigationController?
    internal weak var mainViewcon: MainViewController?
    internal weak var rootVC: RootViewController?

    internal var isUseAllBerry = PublishSubject<Bool>()
    internal var sharedChargerIdFromDynamicLink: String?
    internal var tempDeepLink: String = ""
    
    internal var apiKey: String {
        #if DEBUG
            "2b3f6ff900362a4bb6885c5383464359"
        #else
            "f15aef8c75f9c08c9c1cfa454ca9e4d5"
        #endif
    }
}
