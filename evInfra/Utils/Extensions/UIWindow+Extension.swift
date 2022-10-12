//
//  UIWindow+Extension.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/05.
//  Copyright © 2022 soft-berry. All rights reserved.
//

extension UIWindow {
    static var key: UIWindow? {        
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}
