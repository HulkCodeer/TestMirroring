//
//  FilterSpeedView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
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
    
    func initView() {
        let view = Bundle.main.loadNibNamed("FilterSpeedView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        let cancelGesture = UIPanGestureRecognizer(target: nil, action:nil)
        cancelGesture.cancelsTouchesInView = false
        self.rangeSliderSpeed.addGestureRecognizer(cancelGesture)
        
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
        rangeSliderSpeed.setupStyle()
        rangeSliderSpeed.setNeedsLayout()
        updateSpeedLabel()
    }
    
    func resetFilter() {
        minSpeed = 0
        maxSpeed = 350
        
        setupView()
    }
    
    func applyFilter() {
        FilterManager.sharedInstance.saveSpeedFilter(min: minSpeed, max: maxSpeed)
    }
    
    func isChanged() -> Bool {
        var changed = false
        if (minSpeed != FilterManager.sharedInstance.filter.minSpeed){
            changed = true
        } else if (maxSpeed != FilterManager.sharedInstance.filter.maxSpeed){
            changed = true
        }
        return changed
    }
    
    @IBAction func onTouchUpSlider(_ sender: Any) {
        if (saveOnChange) {
           applyFilter()
        }
        delegate?.onChangedFilter(type: .speed)
    }
    
    func update() {
        minSpeed = FilterManager.sharedInstance.filter.minSpeed
        maxSpeed = FilterManager.sharedInstance.filter.maxSpeed
        
        setupView()
    }
    
    func updateSpeedLabel() {
        var title = ""
        if (minSpeed == 0 && maxSpeed == 350) {
            title = "완속 ~ 350kW"
        } else if (minSpeed == maxSpeed){
            if (minSpeed == 0) {
                title = "완속~완속"
            } else {
                title = "\(minSpeed)kW"
            }
        } else {
            if (minSpeed == 0) {
                title = "완속 ~ \(maxSpeed)kW"
            } else {
                title = "\(minSpeed) ~ \(maxSpeed)kW"
            }
        }
        
        lbSpeed.text = title
    }
}

extension FilterSpeedView: RangeSeekSliderDelegate {

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        self.minSpeed = Int(minValue)
        self.maxSpeed = Int(maxValue)
        
        updateSpeedLabel()
    }

    func didStartTouches(in slider: RangeSeekSlider) {
    }

    func didEndTouches(in slider: RangeSeekSlider) {
    }
}
