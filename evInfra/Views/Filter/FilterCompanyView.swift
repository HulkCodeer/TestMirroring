//
//  FilterCompanyView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

class FilterCompanyView: UIView {
    @IBOutlet var switchAll: UISwitch!
    @IBOutlet var switchCard: UISwitch!
    @IBOutlet var topView: UIView!
    @IBOutlet var collectionView: DynamicCollectionView!
    
    var allSelect :Bool = true
    var tagList = Array<TagValue>()
    var companyList = Array<CompanyInfoDto>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        let view = Bundle.main.loadNibNamed("FilterCompanyView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        prepareTagList()
        setUpUI()
    }
    
    func getHeightSize() -> CGFloat {
        return topView.layer.height + collectionView.layer.height + 16
    }
    
    func prepareTagList() {
        companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        for company in companyList {
            if let iconName = company.icon_name {
                if let icon = ImageMarker.companyImg(company: iconName){
                    tagList.append(TagValue(title:company.name!, img:icon, selected: company.is_visible))
                    if !company.is_visible {
                        allSelect = false
                    }
                }
            }
        }
    }
    
    @IBAction func onCardFilterChanged(_ sender: Any) {
        
        if switchCard.isOn {
            for company in companyList {
                for item in tagList {
                    if let compName = company.name {
                        if item.title.equals(compName) {
                            item.selected = company.recommend ?? false
                        }
                    }
                }
            }
        } else {
            for company in companyList {
                for item in tagList {
                    if (company.name == item.title){
                        item.selected = company.is_visible
                    }
                }
            }
        }
        updateSwitch()
        collectionView.reloadData()
    }
    
    @IBAction func onSwitchValueChanged(_ sender: Any) {
        for item in tagList {
            item.selected = switchAll.isOn
        }
        updateSwitch()
        switchCard.isOn = false
        collectionView.reloadData()
    }
    
    func setUpUI(){
        let layout = TagFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "TagListViewCell", bundle: nil), forCellWithReuseIdentifier: "tagListViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        updateSwitch()
    }
    
    func updateSwitch() {
        allSelect = true
        for item in tagList {
            if !item.selected {
                allSelect = false
            }
        }
        switchAll.setOn(allSelect, animated: true)
    }
    
    func resetFilter() {
        for item in tagList {
            item.selected = true
        }
        collectionView.reloadData()
        switchAll.setOn(true, animated: true)
    }
    
    func applyFilter() {
        for company in companyList {
            for item in tagList {
                if (company.name == item.title){
                    if let companyId = company.company_id {
                        ChargerManager.sharedInstance.updateCompanyVisibility(isVisible: item.selected, companyID: companyId)
                        continue
                    }
                }
            }
        }
        FilterManager.sharedInstance.updateCompanyFilter()
    }
    
    func isChanged() -> Bool {
        var changed = false
        for company in companyList {
            for item in tagList {
                if (company.name == item.title){
                    if (company.is_visible != item.selected){
                        changed = true
                        break
                    }
                }
            }
        }
        return changed
    }
}

// MARK: - Collectionview Methods
extension FilterCompanyView : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagListViewCell", for: indexPath) as!
                TagListViewCell
        cell.cellConfig(arrData: tagList, index: indexPath.row)
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
extension FilterCompanyView : DelegateTagListViewCell{
    func tagClicked(index: Int, value: Bool) {
        // tag selected
        tagList[index].selected = value
        switchCard.isOn = false
        updateSwitch()
    }
}
class DynamicCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }
}
