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
    
    var saveOnChange: Bool = false
    var delegate: DelegateFilterChange?
    
    private var minSpeed = 0
    private var maxSpeed = 350
    
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
        
        rangeSliderSpeed.delegate = self
        
        rangeSliderSpeed.minValue = 0.0
        rangeSliderSpeed.maxValue = 350.0
        rangeSliderSpeed.step = 50
        
        minSpeed = FilterManager.sharedInstance.filter.minSpeed
        maxSpeed = FilterManager.sharedInstance.filter.maxSpeed
        
        setupView()
    }
    
    func setupView() {
        rangeSliderSpeed.selectedMinValue = CGFloat(minSpeed)
        rangeSliderSpeed.selectedMaxValue = CGFloat(maxSpeed)
        rangeSliderSpeed.layoutIfNeeded()
        let str: String = "" + (minSpeed == 0 ? "완속" : "\(minSpeed)") + "~\(maxSpeed)kW"
        lbSpeed.text = str
    }
    
    func resetFilter() {
        minSpeed = 0
        maxSpeed = 350
        
        setupView()
    }
    
    func applyFilter() {
        FilterManager.sharedInstance.saveSpeedFilter(min: minSpeed, max: maxSpeed)
    }
}

extension FilterSpeedView: RangeSeekSliderDelegate {

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        self.minSpeed = Int(minValue)
        self.maxSpeed = Int(maxValue)
        let str: String = "" + (minSpeed == 0 ? "완속" : "\(minSpeed)") + "~\(maxSpeed)kW"
        print(str)
        lbSpeed.text = str
        if (saveOnChange) {
           applyFilter()
        }
        delegate?.onChangedFilter()
    }

    func didStartTouches(in slider: RangeSeekSlider) {
    }

    func didEndTouches(in slider: RangeSeekSlider) {
    }
}
