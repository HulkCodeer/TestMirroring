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
    @IBOutlet var collectionView: UICollectionView!
    
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
    
    func prepareTagList() {
        companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        for company in companyList {
            if let iconName = company.icon_name {
                if let icon = ImageMarker.companyImg(company: iconName){
                    tagList.append(TagValue(title:company.name!, img:icon, selected: true))
                }
            }
        }
    }

    func setUpUI(){
        let layout = TagFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "TagListViewCell", bundle: nil), forCellWithReuseIdentifier: "tagListViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
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
        var imgShow = false
        if (tagList[indexPath.row].img != nil){
            imgShow = true
        }
        return cell.getInteresticSize(strText: strText, cv: collectionView, imgShow:imgShow)
    }
    
    func resetFilter() {
        
    }
    
    func applyFilter() {
        
    }
}


// MARK: - Delegate of Collection Cell
extension FilterCompanyView : DelegateTagListViewCell{
    func tagClicked(index: Int, value: Bool) {
        // tag selected
        print("clicked position : \(index)")
    }
}
