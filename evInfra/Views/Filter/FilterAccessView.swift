//
//  FilterAccessView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import EasyTipView

class FilterAccessView: UIView {
    @IBOutlet var btnInfo: UIButton!
    
    @IBOutlet var btnPublic: UIView!
    @IBOutlet var btnNonPublic: UIView!
    
    @IBOutlet var ivPublic: UIImageView!
    @IBOutlet var lbPublic: UILabel!
    @IBOutlet var ivNonPublic: UIImageView!
    @IBOutlet var lbNonPublic: UILabel!
    
    var publicSel = true
    var nonPublicSel = false
    
    let bgEnColor: UIColor = UIColor(named: "gr-6")!
    let bgDisColor: UIColor = UIColor(named: "content-tertiary")!
    
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
    
    @IBAction func onClickInfo(_ sender: Any) {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = UIColor(named: "content-secondary")!
        preferences.drawing.foregroundColor = UIColor(named: "background-secondary")!
        preferences.drawing.textAlignment = NSTextAlignment.center
        
        preferences.drawing.arrowPosition = .left
        
        preferences.animating.dismissTransform = CGAffineTransform(translationX: -30, y: -100)
        preferences.animating.showInitialTransform = CGAffineTransform(translationX: 30, y: 100)
        preferences.animating.showInitialAlpha = 0
        preferences.animating.showDuration = 1
        preferences.animating.dismissDuration = 1
        
        let text = "비개방충전소 : 충전소 설치 건물 거주/이용/관계자 외엔 사용이 불가한 곳"
        EasyTipView.show(forView: self.btnInfo,
            withinSuperview: self,
            text: text,
            preferences: preferences)
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
        delegate?.onChangedFilter(type: .access)
    }
    
    func resetFilter() {
        publicSel = true
        nonPublicSel = true
        
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
