//
//  UsePointController.swift
//  evInfra
//
//  Created by Shin Park on 07/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material

class UsePointController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "포인트 사용"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}
