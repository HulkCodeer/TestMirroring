//
//  FilterAccessView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import EasyTipView
import UIKit
import AVFAudio

internal final class FilterAccessView: UIView {
    @IBOutlet var btnInfo: UIButton!
    
    @IBOutlet var btnPublic: UIView!
    @IBOutlet var btnNonPublic: UIView!
    
    @IBOutlet var ivPublic: UIImageView!
    @IBOutlet var lbPublic: UILabel!
    @IBOutlet var ivNonPublic: UIImageView!
    @IBOutlet var lbNonPublic: UILabel!
    
    @IBOutlet var publicButton: UIButton!
    @IBOutlet var nonPublicButton: UIButton!
    
    private var isOnEasyTipView: Bool = false
    private let bgEnColor: UIColor = Colors.gr6.color
    private let bgDisColor: UIColor = Colors.contentTertiary.color
    
    internal weak var delegate: DelegateFilterChange?
   
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
       
        publicButton.isSelected = FilterManager.sharedInstance.filter.isPublic
        nonPublicButton.isSelected = FilterManager.sharedInstance.filter.isNonPublic
        setPublicButtonState()
        setNonPublicButtonState()
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
    
    @IBAction func publicButtonTapped(_ sender: Any) {
        publicButton.isSelected = !publicButton.isSelected
        setPublicButtonState()
    }
    
    @IBAction func nonPublicButtonTapped(_ sender: Any) {
        nonPublicButton.isSelected = !nonPublicButton.isSelected
        setNonPublicButtonState()
    }
    
    private func setPublicButtonState() {
        if publicButton.isSelected {
            ivPublic.tintColor = bgEnColor
            lbPublic.textColor = bgEnColor
        } else {
            ivPublic.tintColor = bgDisColor
            lbPublic.textColor = bgDisColor
        }
        delegate?.onChangedFilter(type: .access)
    }
    
    private func setNonPublicButtonState() {
        if nonPublicButton.isSelected {
            ivNonPublic.tintColor = bgEnColor
            lbNonPublic.textColor = bgEnColor
        } else {
            ivNonPublic.tintColor = bgDisColor
            lbNonPublic.textColor = bgDisColor
        }
        delegate?.onChangedFilter(type: .access)
    }
    
    internal func resetFilter() {
        publicButton.isSelected = true
        nonPublicButton.isSelected = true
        setPublicButtonState()
        setNonPublicButtonState()
    }
    
    internal func applyFilter() {
        FilterManager.sharedInstance.saveAccessFilter(isPublic: publicButton.isSelected, nonPublic: nonPublicButton.isSelected)
    }
    
    internal func isChanged() -> Bool {
        guard publicButton.isSelected == FilterManager.sharedInstance.filter.isPublic else { return true }
        guard nonPublicButton.isSelected == FilterManager.sharedInstance.filter.isNonPublic else { return true }
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
