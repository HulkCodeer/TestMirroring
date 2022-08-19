//
//  FilterTypeView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation


protocol DelegateSlowTypeChange: class {
    func onChangeSlowType(slowOn: Bool)
}

internal final class FilterTypeView: UIView {
    // MARK: UI
    
    @IBOutlet var tagCollectionView: UICollectionView!
    @IBOutlet var carSettingView: UIView!
    @IBOutlet var switchCarSetting: UISwitch!
    
    // MARK: VARIABLE
    
    internal var tagList = Array<TagValue>()
    
    internal weak var slowTypeChangeDelegate: DelegateSlowTypeChange?
    internal var saveOnChange: Bool = false
    internal weak var delegate: DelegateFilterChange?
    
    // MARK: SYSTEM FUNC
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        let view = Bundle.main.loadNibNamed("FilterTypeView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        prepareTagList()
                        
        tagCollectionView.collectionViewLayout = TagFlowLayout()
        tagCollectionView.register(UINib(nibName: "TagListViewCell", bundle: nil), forCellWithReuseIdentifier: "tagListViewCell")
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.reloadData()
                                
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            self.switchCarSetting.isUserInteractionEnabled = isLogin
        }
    }
    
    @IBAction func onSwitchClicked(_ sender: Any) {
        MemberManager.shared.tryToLoginCheck { [weak self] isLogin in
            guard !isLogin, let self = self else { return }
            MemberManager.shared.showLoginAlert(completion: { (result) -> Void in
                self.switchCarSetting.isOn = false
            })
        }
    }
    
    @IBAction func onSwitchValueChange(_ sender: Any) {
        if (switchCarSetting.isOn) {
            MemberManager.shared.tryToLoginCheck { [weak self] isLogin in
                guard isLogin, let self = self else { return }
                self.setForCarType()
            }
            
        } else { // 차량필터 해제 시
            if (!isChanged()) { // 변경사항 없으면 초기값
                resetFilter()
            } else  { // 변경사항 있을때 이전 필터값 복원
                update()
            }
        }
        UserDefault().registerBool(key: UserDefault.Key.FILTER_MYCAR, val: switchCarSetting.isOn)
        sendTypeChange()
    }
    
    func setForCarType(){
        var carType = UserDefault().readInt(key: UserDefault.Key.MB_CAR_TYPE);
        switch(carType) {
            case Const.CHARGER_TYPE_DCCOMBO, Const.CHARGER_TYPE_DCDEMO
                , Const.CHARGER_TYPE_AC, Const.CHARGER_TYPE_SLOW
                , Const.CHARGER_TYPE_SUPER_CHARGER, Const.CHARGER_TYPE_DESTINATION:
                break
            default:
                carType = Const.CHARGER_TYPE_DCCOMBO
        }
        
        for item in tagList {
            item.selected = carType == item.index
        }
        tagCollectionView.reloadData()
    }
    
    func setSlowTypeOn(slowTypeOn: Bool) {
        tagList[3].selected = slowTypeOn
        tagList[5].selected = slowTypeOn
        
        if (saveOnChange) {
            FilterManager.sharedInstance.saveTypeFilter(index: tagList[3].index, val: slowTypeOn)
            FilterManager.sharedInstance.saveTypeFilter(index: tagList[5].index, val: slowTypeOn)
        }
        
        tagCollectionView.reloadData()
        if let delegate = delegate {
            delegate.onChangedFilter(type: .type)
        }
    }
    
    func sendTypeChange() {
        let changed = tagList[3].selected || tagList[5].selected
        if let delegate = slowTypeChangeDelegate {
            delegate.onChangeSlowType(slowOn: changed)
        }
    }
    
    func prepareTagList() {
        var selected = FilterManager.sharedInstance.filter.dcCombo
        tagList.append(TagValue(title:"DC콤보", img:"ic_charger_dc_combo_md", selected:selected, index: Const.CHARGER_TYPE_DCCOMBO))
        
        selected = FilterManager.sharedInstance.filter.dcDemo
        tagList.append(TagValue(title:"DC차데모", img:"ic_charger_dc_demo_md", selected:selected, index: Const.CHARGER_TYPE_DCDEMO))
        
        selected = FilterManager.sharedInstance.filter.ac3
        tagList.append(TagValue(title:"AC 3상", img:"ic_charger_acthree_md", selected:selected, index: Const.CHARGER_TYPE_AC))
        
        selected = FilterManager.sharedInstance.filter.slow
        tagList.append(TagValue(title:"완속", img:"ic_charger_slow_md", selected:selected, index: Const.CHARGER_TYPE_SLOW))
        
        selected = FilterManager.sharedInstance.filter.superCharger
        tagList.append(TagValue(title:"슈퍼차저", img:"ic_charger_super_md", selected:selected, index: Const.CHARGER_TYPE_SUPER_CHARGER))
        
        selected = FilterManager.sharedInstance.filter.destination
        tagList.append(TagValue(title:"데스티네이션", img:"ic_charger_slow_md", selected:selected, index: Const.CHARGER_TYPE_DESTINATION))
    }
    
    func resetFilter() {
        for item in tagList {
            item.selected = !(item.index == Const.CHARGER_TYPE_SLOW || item.index == Const.CHARGER_TYPE_DESTINATION)
        }
        tagCollectionView.reloadData()
        switchCarSetting.setOn(false, animated: true)
    }
    
    func applyFilter() {
        for item in tagList {
            FilterManager.sharedInstance.saveTypeFilter(index: item.index, val: item.selected)
        }
    }
    
    func showExpandView() {
        carSettingView.isHidden = false
    }
    
    func isChanged() -> Bool {
        var changed = false
        if (tagList[0].selected != FilterManager.sharedInstance.filter.dcCombo){
            changed = true
        } else if (tagList[1].selected != FilterManager.sharedInstance.filter.dcDemo){
            changed = true
        } else if (tagList[2].selected != FilterManager.sharedInstance.filter.ac3){
            changed = true
        } else if (tagList[3].selected != FilterManager.sharedInstance.filter.slow){
            changed = true
        } else if (tagList[4].selected != FilterManager.sharedInstance.filter.superCharger){
            changed = true
        } else if (tagList[5].selected != FilterManager.sharedInstance.filter.destination){
            changed = true
        }
        return changed
    }
    
    func update() {
        tagList.removeAll()
        prepareTagList()
        tagCollectionView.reloadData()
    }
}

// MARK: - Collectionview Methods
extension FilterTypeView : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagListViewCell", for: indexPath) as!
                TagListViewCell
        cell.cellConfig(arrData: tagList, index: indexPath.row)
        cell.isUserInteractionEnabled = true
        cell.delegateTagClick = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath : IndexPath) -> CGSize {
        
        let strText = tagList[indexPath.row].title
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagListViewCell", for: indexPath) as! TagListViewCell
        return cell.getInteresticSize(strText: strText, cv: collectionView)
    }
}

// MARK: - Delegate of Collection Cell
extension FilterTypeView : DelegateTagListViewCell{
    func tagClicked(index: Int, value: Bool) {
        // tag selected
        tagList[index].selected = value
        if (saveOnChange) {
            FilterManager.sharedInstance.saveTypeFilter(index: tagList[index].index, val: value)
        }
        if index == 3 || index == 5 {
            sendTypeChange()
        } else {
            self.delegate?.onChangedFilter(type: .type)
        }
    }
}
