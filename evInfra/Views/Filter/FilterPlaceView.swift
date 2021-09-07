//
//  FilterPlaceView.swift
//  evInfra
//
//  Created by SH on 2021/08/11.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class FilterPlaceView: UIView {
    @IBOutlet var btnIndoor: UIView!
    @IBOutlet var btnOutdoor: UIView!
    @IBOutlet var btnCanopy: UIView!
    
    @IBOutlet var ivIndoor: UIImageView!
    @IBOutlet var lbIndoor: UILabel!
    
    @IBOutlet var ivOutdoor: UIImageView!
    @IBOutlet var lbOutdoor: UILabel!
    @IBOutlet var ivCanopy: UIImageView!
    @IBOutlet var lbCanopy: UILabel!
    
    var saveOnChange: Bool = false
    var delegate: DelegateFilterChange?
    
    private var indoorSel = true
    private var outdoorSel = true
    private var canopySel = true
    
    let bgEnColor: UIColor = UIColor(named: "content-positive")!
    let bgDisColor: UIColor = UIColor(named: "content-tertiary")!
    
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
        
        btnIndoor.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickIndoor (_:))))
        btnOutdoor.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickOutdoor (_:))))
        btnCanopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickCanopy (_:))))
        
        indoorSel = FilterManager.sharedInstance.filter.isIndoor
        outdoorSel = FilterManager.sharedInstance.filter.isOutdoor
        canopySel = FilterManager.sharedInstance.filter.isCanopy
        
        selectItem(index: 0)
        selectItem(index: 1)
        selectItem(index: 2)
    }
    
    @objc func onClickIndoor(_ sender:UITapGestureRecognizer){
        indoorSel = !indoorSel
        selectItem(index: 0)
        if (saveOnChange) {
            applyFilter()
        }
        delegate?.onChangedFilter(type: .place)
    }
    
    @objc func onClickOutdoor(_ sender:UITapGestureRecognizer){
        outdoorSel = !outdoorSel
        selectItem(index: 1)
        if (saveOnChange) {
            applyFilter()
        }
        delegate?.onChangedFilter(type: .place)
    }
    
    @objc func onClickCanopy(_ sender:UITapGestureRecognizer){
        canopySel = !canopySel
        selectItem(index: 2)
        if (saveOnChange) {
            applyFilter()
        }
        delegate?.onChangedFilter(type: .place)
    }
    
    func selectItem(index: Int){
        if(index == 0) {
            if (indoorSel){
                ivIndoor.tintColor = bgEnColor
                lbIndoor.textColor = bgEnColor
            } else {
                ivIndoor.tintColor = bgDisColor
                lbIndoor.textColor = bgDisColor
            }
        } else if(index == 1) {
            if (outdoorSel){
                ivOutdoor.tintColor = bgEnColor
                lbOutdoor.textColor = bgEnColor
            } else {
                ivOutdoor.tintColor = bgDisColor
                lbOutdoor.textColor = bgDisColor
            }
        } else if(index == 2) {
            if (canopySel){
                ivCanopy.tintColor = bgEnColor
                lbCanopy.textColor = bgEnColor
            } else {
                ivCanopy.tintColor = bgDisColor
                lbCanopy.textColor = bgDisColor
            }
        }
    }
        
    func resetFilter() {
        indoorSel = true
        outdoorSel = true
        canopySel = true
        
        selectItem(index: 0)
        selectItem(index: 1)
        selectItem(index: 2)
    }
    
    func applyFilter() {
        FilterManager.sharedInstance.savePlaceFilter(indoor: indoorSel, outdoor: outdoorSel, canopy: canopySel)
    }
    
    func update() {
        indoorSel = FilterManager.sharedInstance.filter.isIndoor
        outdoorSel = FilterManager.sharedInstance.filter.isOutdoor
        canopySel = FilterManager.sharedInstance.filter.isCanopy
        
        selectItem(index: 0)
        selectItem(index: 1)
        selectItem(index: 2)
    }
    
    func isChanged() -> Bool {
        var changed = false
        if (indoorSel != FilterManager.sharedInstance.filter.isIndoor){
            changed = true
        } else if (outdoorSel != FilterManager.sharedInstance.filter.isOutdoor){
            changed = true
        } else if (canopySel != FilterManager.sharedInstance.filter.isCanopy){
            changed = true
        }
        return changed
    }
}
