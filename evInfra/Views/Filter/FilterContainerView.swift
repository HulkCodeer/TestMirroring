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
    }
    
    func isSameView(type: FilterType) ->Bool{
        return currType == type
    }
    
    func showFilterView(type: FilterType){
        currType = type
        // bring view to front
    }
}
