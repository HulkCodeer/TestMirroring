//
//  IntroView.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 13..
//  Copyright © 2018년 bulacode. All rights reserved.
//

import UIKit

class IntroView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var progressLayer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    var maxCount = 0
    func showProgressLayer(isShow: Bool){
        progressLayer.visiblity(gone: !isShow)
    }
    
    func setProgressMaxCount(maxCount: Int){
        self.maxCount = maxCount
        self.progressBar.progress = 0.0
        if(maxCount == 0){
            showProgressLayer(isShow: false)
        }
    }
    
    func setProgress(progressCount: Int){
        let rate = Float(progressCount) / Float(self.maxCount)
        progressBar.setProgress(rate, animated: true)
        progressLabel.text = "(\(progressCount)/\(self.maxCount))"
        
    }
}
