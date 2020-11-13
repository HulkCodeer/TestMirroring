//
//  Snackbar.swift
//  evInfra
//
//  Created by Shin Park on 20/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialSnackbar

class Snackbar {
    
    let snackbarMessage = MDCSnackbarMessage()
    let action = MDCSnackbarMessageAction()
    
    public func show(message: String) {
        snackbarMessage.duration = 2.0
        snackbarMessage.text = message
        MDCSnackbarManager.default.show(snackbarMessage)
    }
    
    public func show(message: String, title: String, actionHandler: @escaping () -> Void) {
        action.handler = actionHandler
        action.title = title
        snackbarMessage.action = action
        snackbarMessage.text = message
        MDCSnackbarManager.default.show(snackbarMessage)
    }
}
