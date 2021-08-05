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
        tagList.append(TagValue(title:"DC콤보", img:"ic_charger_dc_combo_sm", selected:false))
        tagList.append(TagValue(title:"DC차데모", img:"ic_charger_dc_demo_sm", selected:false))
        tagList.append(TagValue(title:"AC 3상", img:"ic_charger_acthree_sm", selected:false))
        tagList.append(TagValue(title:"완속", img:"ic_charger_slow_sm", selected:true))
        tagList.append(TagValue(title:"슈퍼차저", img:"ic_charger_super_sm", selected:false))
        tagList.append(TagValue(title:"데스티네이션", img:"ic_charger_slow_sm", selected:false))
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
        if (tagList[indexPath.row].img.isEmpty){
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

