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
    
    var tagList = Array<TagValue>()
    
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
        tagList.append(TagValue(title:"DC콤보", img:"ic_charger_dc_combo_md", selected:false))
        tagList.append(TagValue(title:"DC차데모", img:"ic_charger_dc_demo_md", selected:false))
        tagList.append(TagValue(title:"AC 3상", img:"ic_charger_acthree_md", selected:false))
        tagList.append(TagValue(title:"완속", img:"ic_charger_slow_md", selected:true))
        tagList.append(TagValue(title:"슈퍼차저", img:"ic_charger_super_md", selected:false))
        tagList.append(TagValue(title:"데스티네이션", img:"ic_charger_slow_md", selected:false))
    }

    func setUpUI(){
        let layout = TagFlowLayout()
        tagCollectionView.collectionViewLayout = layout
        tagCollectionView.register(UINib(nibName: "TagListViewCell", bundle: nil), forCellWithReuseIdentifier: "tagListViewCell")
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
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
        var imgShow = false
        if (tagList[indexPath.row].img != nil){
            imgShow = true
        }
        return cell.getInteresticSize(strText: strText, cv: collectionView, imgShow:imgShow)
    }
}


// MARK: - Delegate of Collection Cell
extension FilterTypeView : DelegateTagListViewCell{
    func tagClicked(index: Int) {
        // tag selected
        print("clicked position : \(index)")
    }
}
