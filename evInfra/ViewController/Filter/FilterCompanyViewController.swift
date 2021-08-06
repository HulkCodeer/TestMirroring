//
//  FilterCompanyViewController.swift
//  evInfra
//
//  Created by SH on 2021/08/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//
import Foundation
class FilterCompanyViewController: UIViewController {
    
    var tagList = Array<TagValue>()
    var companyList = Array<CompanyInfoDto>()
    @IBOutlet weak var tagCollectionview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTagList()
        setUpUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
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
        tagCollectionview.collectionViewLayout = layout
        tagCollectionview.register(UINib(nibName: "TagListViewCell", bundle: nil), forCellWithReuseIdentifier: "tagListViewCell")
        tagCollectionview.delegate = self
        tagCollectionview.dataSource = self
        tagCollectionview.reloadData()
    }
}

// MARK: - Collectionview Methods
extension FilterCompanyViewController : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
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
    
}


// MARK: - Delegate of Collection Cell
extension FilterCompanyViewController : DelegateTagListViewCell{
    func tagClicked(index: Int) {
        // tag selected
        print("clicked position : \(index)")
    }
}

