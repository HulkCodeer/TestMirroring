//
//  UITextField.swift
//  evInfra
//
//  Created by bulacode on 17/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit.UITextField

extension UITextField {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text!)
    }
}
