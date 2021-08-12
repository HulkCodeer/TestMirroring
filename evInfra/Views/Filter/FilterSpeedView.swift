//
//  FilterSpeedView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import RangeSeekSlider
class FilterSpeedView: UIView {
    
    @IBOutlet var lbSpeed: UILabel!
    @IBOutlet var rangeSliderSpeed: RangeSeekSlider!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        let view = Bundle.main.loadNibNamed("FilterSpeedView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
    }
}
