//
//  GlobalDefine.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal final class GlobalDefine: NSObject {
    internal static var shared = GlobalDefine()
    
    internal weak var mainNavi: AppNavigationController?
}



