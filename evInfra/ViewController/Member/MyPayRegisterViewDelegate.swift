//
//  MyPayRegisterViewDelegate.swift
//  evInfra
//
//  Created by bulacode on 23/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MyPayRegisterViewDelegate: class {
    func finishRegisterResult(json: JSON)
    func onCancelRegister()
}
