//
//  FilterPriceView.swift
//  evInfra
//
//  Created by SH on 2021/08/11.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import M13Checkbox

@IBDesignable
class FilterPriceView: UIView {
    @IBOutlet var checkPaid: M13Checkbox!
    @IBOutlet var checkFree: M13Checkbox!
    
    var saveOnChange: Bool = false
    var delegate: DelegateFilterChange?
    
    private var isFree: Bool = true
    private var isPaid: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        let view = Bundle.main.loadNibNamed("FilterPriceView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        isFree = FilterManager.sharedInstance.filter.isFree
        isPaid = FilterManager.sharedInstance.filter.isPaid
        setView()
    }
    
    func setView() {
        checkPaid.checkState = isPaid ? .checked : .unchecked
        checkFree.checkState = isFree ? .checked : .unchecked
    }
    
    @IBAction func onClickCheckPaid(_ sender: Any) {
        isPaid = !isPaid
        setView()
        if (saveOnChange) {
            applyFilter()
        }
        delegate?.onChangedFilter()
    }
    
    @IBAction func onClickCheckFree(_ sender: Any) {
        isFree = !isFree
        setView()
        if (saveOnChange) {
            applyFilter()
        }
        delegate?.onChangedFilter()
    }
    
    func resetFilter() {
        isFree = true
        isPaid = true
        setView()
    }
    
    func applyFilter() {
        FilterManager.sharedInstance.savePriceFilter(free: isFree, paid: isPaid)
    }
}
