//
//  FilterTypeView.swift
//  evInfra
//
//  Created by SH on 2021/08/12.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

class FilterTypeView: UIView {
    @IBOutlet var tagCollectionView: UICollectionView!
    
    private var tagList = Array<TagValue>()
    var saveOnChange: Bool = false
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
        let view = Bundle.main.loadNibNamed("FilterTypeView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        prepareTagList()
        setUpUI()
    }
    
    func prepareTagList() {
        var selected = FilterManager.sharedInstance.filter.dcCombo
        tagList.append(TagValue(title:"DC콤보", img:"ic_charger_dc_combo_md", selected:selected))
        
        selected = FilterManager.sharedInstance.filter.dcDemo
        tagList.append(TagValue(title:"DC차데모", img:"ic_charger_dc_demo_md", selected:selected))
        
        selected = FilterManager.sharedInstance.filter.ac3
        tagList.append(TagValue(title:"AC 3상", img:"ic_charger_acthree_md", selected:selected))
        
        selected = FilterManager.sharedInstance.filter.slow
        tagList.append(TagValue(title:"완속", img:"ic_charger_slow_md", selected:selected))
        
        selected = FilterManager.sharedInstance.filter.superCharger
        tagList.append(TagValue(title:"슈퍼차저", img:"ic_charger_super_md", selected:selected))
        
        selected = FilterManager.sharedInstance.filter.destination
        tagList.append(TagValue(title:"데스티네이션", img:"ic_charger_slow_md", selected:selected))
    }

    func setUpUI(){
        let layout = TagFlowLayout()
        tagCollectionView.collectionViewLayout = layout
        tagCollectionView.register(UINib(nibName: "TagListViewCell", bundle: nil), forCellWithReuseIdentifier: "tagListViewCell")
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.reloadData()
    }
    
    func resetFilter() {
        for item in tagList {
            item.selected = (item.title != "완속")
        }
        tagCollectionView.reloadData()
    }
    
    func applyFilter() {
        FilterManager.sharedInstance.saveTypeFilter(index: 0, val: tagList[0].selected)
        FilterManager.sharedInstance.saveTypeFilter(index: 1, val: tagList[1].selected)
        FilterManager.sharedInstance.saveTypeFilter(index: 2, val: tagList[2].selected)
        FilterManager.sharedInstance.saveTypeFilter(index: 3, val: tagList[3].selected)
        FilterManager.sharedInstance.saveTypeFilter(index: 4, val: tagList[4].selected)
        FilterManager.sharedInstance.saveTypeFilter(index: 5, val: tagList[5].selected)
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
            FilterManager.sharedInstance.saveTypeFilter(index: index, val: value)
        }
        self.delegate?.onChangedFilter()
    }
}
