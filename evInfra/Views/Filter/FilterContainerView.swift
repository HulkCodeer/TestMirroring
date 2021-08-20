//
//  FilterContainerView.swift
//  evInfra
//
//  Created by SH on 2021/08/11.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
protocol DelegateFilterContainerView {
    func changedFilter()
}
class FilterContainerView: UIView {
    
    @IBOutlet var filterContainerView: UIView!
    @IBOutlet var filterTypeView: FilterTypeView!
    @IBOutlet var filterSpeedView: FilterSpeedView!
    @IBOutlet var filterPriceView: FilterPriceView!
    @IBOutlet var filterRoadView: FilterRoadView!
    @IBOutlet var filterPlaceView: FilterPlaceView!
    
    var delegate: DelegateFilterContainerView?
    var currType: FilterType = FilterType.none
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        let view = Bundle.main.loadNibNamed("FilterContainerView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        filterTypeView.saveOnChange = true
        filterSpeedView.saveOnChange = true
        filterRoadView.saveOnChange = true
        filterPlaceView.saveOnChange = true
        filterPriceView.saveOnChange = true
        
        filterTypeView.delegate = self
        filterSpeedView.delegate = self
        filterRoadView.delegate = self
        filterPlaceView.delegate = self
        filterPriceView.delegate = self
    }
    
    func isSameView(type: FilterType) ->Bool{
        if (currType == type){
            currType = .none
            return true
        }

        return false
    }
    
    func showFilterView(type: FilterType){
        currType = type
        
        switch type {
        case .price:
            filterContainerView.bringSubview(toFront: filterPriceView!)
        case .speed:
            filterContainerView.bringSubview(toFront: filterSpeedView!)
        case .place:
            filterContainerView.bringSubview(toFront: filterPlaceView!)
        case .road:
            filterContainerView.bringSubview(toFront: filterRoadView!)
        case .type:
            filterContainerView.bringSubview(toFront: filterTypeView!)
        case .none:
            break;
        }
    }
    
    func updateFilters() {
        filterPriceView.update()
        filterSpeedView.update()
        filterPlaceView.update()
        filterRoadView.update()
        filterTypeView.update()
    }
}

extension FilterContainerView: DelegateFilterChange{
    func onChangedFilter() {
        delegate?.changedFilter()
    }
}
