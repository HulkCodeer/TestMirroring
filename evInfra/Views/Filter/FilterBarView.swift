//
//  FilterBarView.swift
//  evInfra
//
//  Created by SH on 2021/08/11.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

protocol DelegateFilterBarView {
    func showFilterContainer(type: FilterType)
    func startFilterSetting()
}

enum FilterType {
    case price
    case speed
    case place
    case road
    case type
    case none
}

class FilterBarView: UIView {
    
    @IBOutlet var btnFilter: UIView!
    var delegate: DelegateFilterBarView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        let view = Bundle.main.loadNibNamed("FilterBarView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onClickTag (_:)))
        btnFilter.addGestureRecognizer(gesture)
    }
    
    @objc func onClickTag(_ sender:UITapGestureRecognizer){
        print("filter btn clicked")
        showFilterView(type: FilterType.price)
    }
    
    func showFilterView(type: FilterType){
        delegate?.showFilterContainer(type: type)
    }
}
