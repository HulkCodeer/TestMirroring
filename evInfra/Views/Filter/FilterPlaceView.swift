//
//  FilterPlaceView.swift
//  evInfra
//
//  Created by SH on 2021/08/11.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import UIKit
class FilterPlaceView: UIView {
    
    @IBOutlet var lbPlace: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        let view = Bundle.main.loadNibNamed("FilterPlaceView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        lbPlace.text = "place"
    }
}
