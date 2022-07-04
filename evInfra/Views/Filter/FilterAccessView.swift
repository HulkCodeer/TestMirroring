//
//  FilterAccessView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import EasyTipView

internal final class FilterAccessView: UIView {
    @IBOutlet var btnInfo: UIButton!
    
    @IBOutlet var btnPublic: UIView!
    @IBOutlet var btnNonPublic: UIView!
    
    @IBOutlet var ivPublic: UIImageView!
    @IBOutlet var lbPublic: UILabel!
    @IBOutlet var ivNonPublic: UIImageView!
    @IBOutlet var lbNonPublic: UILabel!
    
    private var publicSel: Bool = true
    private var nonPublicSel: Bool = false
    private var isOnEasyTipView: Bool = false

    private let bgEnColor: UIColor = Colors.gr6.color
    private let bgDisColor: UIColor = Colors.contentTertiary.color
    
    internal var delegate: DelegateFilterChange?
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView(){
        guard let view = Bundle.main.loadNibNamed("FilterAccessView", owner: self, options: nil)?.first as? UIView else { return }
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
        guard !isOnEasyTipView else { return }
        isOnEasyTipView = !isOnEasyTipView
        
        var preferences = EasyTipView.Preferences()
        
        preferences.drawing.backgroundColor = Colors.contentSecondary.color
        preferences.drawing.foregroundColor = Colors.backgroundSecondary.color
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
                         preferences: preferences,
                         delegate: self)
    }

    @objc func onClickPublic(_ sender: UITapGestureRecognizer) {
        publicSel = !publicSel
        selectItem(index: 0)
    }
    
    @objc func onClickNonPublic(_ sender: UITapGestureRecognizer) {
        nonPublicSel = !nonPublicSel
        selectItem(index: 1)
    }
    
    private func selectItem(index: Int) {
        switch index {
        case 0:
            guard publicSel else {
                ivPublic.tintColor = bgDisColor
                lbPublic.textColor = bgDisColor
                return
            }
            ivPublic.tintColor = bgEnColor
            lbPublic.textColor = bgEnColor
        case 1:
            guard nonPublicSel else {
                ivNonPublic.tintColor = bgDisColor
                lbNonPublic.textColor = bgDisColor
                return
            }
            ivNonPublic.tintColor = bgEnColor
            lbNonPublic.textColor = bgEnColor
        default: break
        }
        delegate?.onChangedFilter(type: .access)
    }
    
    internal func resetFilter() {
        publicSel = true
        nonPublicSel = true
        
        selectItem(index: 0)
        selectItem(index: 1)
    }
    
    internal func applyFilter() {
        FilterManager.sharedInstance.saveAccessFilter(isPublic: publicSel, nonPublic: nonPublicSel)
    }
    
    internal func isChanged() -> Bool {
        guard publicSel == FilterManager.sharedInstance.filter.isPublic else { return true }
        guard nonPublicSel == FilterManager.sharedInstance.filter.isNonPublic else { return true }
        return false
    }
}

// MARK: - EasyTipViewDelegate
extension FilterAccessView: EasyTipViewDelegate {
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {}
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        isOnEasyTipView = false
    }
}
