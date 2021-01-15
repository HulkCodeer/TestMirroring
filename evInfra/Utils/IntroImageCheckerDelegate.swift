//
//  IntroImageCheckerDelegate.swift
//  evInfra
//
//  Created by SH on 2021/01/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

protocol IntroImageCheckerDelegate {
    func finishCheckIntro(imgName : String, path : String)
    func showDefaultImage()
}
