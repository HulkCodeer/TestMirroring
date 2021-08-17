//
//  FilterAccessView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

class FilterAccessView: UIView {
    @IBOutlet var btnPublic: UIView!
    @IBOutlet var btnNonPublic: UIView!
    
    @IBOutlet var ivPublic: UIImageView!
    @IBOutlet var lbPublic: UILabel!
    @IBOutlet var ivNonPublic: UIImageView!
    @IBOutlet var lbNonPublic: UILabel!
    
    var publicSel = true
    var nonPublicSel = false
    
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
        let view = Bundle.main.loadNibNamed("FilterAccessView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        btnPublic.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickPublic (_:))))
        btnNonPublic.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickNonPublic (_:))))
        
        publicSel = FilterManager.sharedInstance.filter.isPublic
        nonPublicSel = FilterManager.sharedInstance.filter.isNonPublic
        
        selectItem(index: 0)
        selectItem(index: 1)
    }
    
    @objc func onClickPublic(_ sender:UITapGestureRecognizer){
        publicSel = !publicSel
        selectItem(index: 0)
    }
    @objc func onClickNonPublic(_ sender:UITapGestureRecognizer){
        nonPublicSel = !nonPublicSel
        selectItem(index: 1)
    }
    
    func selectItem(index: Int){
        if(index == 0) {
            if (publicSel){
                ivPublic.tintColor = bgEnColor
                lbPublic.textColor = bgEnColor
            } else {
                ivPublic.tintColor = bgDisColor
                lbPublic.textColor = bgDisColor
            }
        } else if(index == 1) {
            if (nonPublicSel){
                ivNonPublic.tintColor = bgEnColor
                lbNonPublic.textColor = bgEnColor
            } else {
                ivNonPublic.tintColor = bgDisColor
                lbNonPublic.textColor = bgDisColor
            }
        }
    }
    
    func resetFilter() {
        publicSel = true
        nonPublicSel = false
        
        selectItem(index: 0)
        selectItem(index: 1)
    }
    
    func applyFilter() {
        FilterManager.sharedInstance.saveAccessFilter(isPublic: publicSel, nonPublic: nonPublicSel)
    }
    
    func isChanged() -> Bool {
        var changed = false
        if (publicSel != FilterManager.sharedInstance.filter.isPublic){
            changed = true
        } else if (nonPublicSel != FilterManager.sharedInstance.filter.isNonPublic){
            changed = true
        }
        return changed
    }
}
