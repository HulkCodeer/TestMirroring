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
    
    var delegate: DelegateFilterChange?
    
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
    
    func resetFilter() {
        
    }
    
    func applyFilter() {
        
    }
}

extension FilterSpeedView: RangeSeekSliderDelegate {

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        
        delegate?.onChangedFilter()
    }

    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }

    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}
