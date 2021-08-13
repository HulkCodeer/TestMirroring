//
//  FilterRoadView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

class FilterRoadView: UIView {
    @IBOutlet var btnGeneral: UIView!
    @IBOutlet var btnHighUp: UIView!
    @IBOutlet var btnHighDown: UIView!
    
    @IBOutlet var ivGeneral: UIImageView!
    @IBOutlet var lbGeneral: UILabel!
    @IBOutlet var ivHighUp: UIImageView!
    @IBOutlet var lbHighUp: UILabel!
    @IBOutlet var ivHighDown: UIImageView!
    @IBOutlet var lbHighDown: UILabel!
    
    var delegate: DelegateFilterChange?
    var generalSel = true
    var highUpSel = true
    var highDownSel = true
    
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
        let view = Bundle.main.loadNibNamed("FilterRoadView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        btnGeneral.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickGeneral (_:))))
        btnHighUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickHighTop (_:))))
        btnHighDown.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickHighDown (_:))))
        
        selectItem(index: 0)
        selectItem(index: 1)
        selectItem(index: 2)
    }
    
    @objc func onClickGeneral(_ sender:UITapGestureRecognizer){
        generalSel = !generalSel
        selectItem(index: 0)
        delegate?.onChangedFilter()
    }
    
    @objc func onClickHighTop(_ sender:UITapGestureRecognizer){
        highUpSel = !highUpSel
        selectItem(index: 1)
        delegate?.onChangedFilter()
    }
    
    @objc func onClickHighDown(_ sender:UITapGestureRecognizer){
        highDownSel = !highDownSel
        selectItem(index: 2)
        delegate?.onChangedFilter()
    }
    
    func selectItem(index: Int){
        if(index == 0) {
            if (generalSel){
                ivGeneral.tintColor = bgEnColor
                lbGeneral.textColor = bgEnColor
            } else {
                ivGeneral.tintColor = bgDisColor
                lbGeneral.textColor = bgDisColor
            }
        } else if(index == 1) {
            if (highUpSel){
                ivHighUp.tintColor = bgEnColor
                lbHighUp.textColor = bgEnColor
            } else {
                ivHighUp.tintColor = bgDisColor
                lbHighUp.textColor = bgDisColor
            }
        } else if(index == 2) {
            if (highDownSel){
                ivHighDown.tintColor = bgEnColor
                lbHighDown.textColor = bgEnColor
            } else {
                ivHighDown.tintColor = bgDisColor
                lbHighDown.textColor = bgDisColor
            }
        }
    }
    
    func resetFilter() {
        
    }
    
    func applyFilter() {
        
    }
}
