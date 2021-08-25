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
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var companyTableView: CompanyTableView!
    var allSelect :Bool = true
    private let GROUP_TITLE = ["A.B.C..", "가", "나", "다", "라", "마", "바", "사", "아", "자", "차", "카", "타", "파", "하", "힣"];

    var groupList = Array<CompanyGroup>()
    
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
        groupList.removeAll()
        var tagList = Array<TagValue>()
        var recommendList = Array<TagValue>()
        var titleIndex = 1
        let companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        let wholeList = companyList.sorted { $0.name!.lowercased() < $1.name!.lowercased() }

        for company in wholeList {
            if let iconName = company.icon_name {
                if let icon = ImageMarker.companyImg(company: iconName){
                    if company.name! >= GROUP_TITLE[titleIndex] {
                        let currentIndex = titleIndex
                        for index in (currentIndex+1)..<GROUP_TITLE.count {
                            if company.name! >= GROUP_TITLE[index] {
                                titleIndex += 1
                            } else {
                                break
                            }
                        }
                        if !tagList.isEmpty {
                            groupList.append(CompanyGroup(title: GROUP_TITLE[titleIndex-1], list: tagList))
                            tagList = Array<TagValue>()
                        }
                        titleIndex += 1
                    }
                    let tag = TagValue(title:company.name!, img:icon, selected: company.is_visible)
                    tagList.append(tag)
                    if company.recommend ?? false {
                        recommendList.append(tag)
                    }

                    if !company.is_visible {
                        allSelect = false
                    }
                }
            }
        }
        if !tagList.isEmpty {
            groupList.append(CompanyGroup(title: GROUP_TITLE[titleIndex-1], list: tagList))
        }

        let abcGroup = groupList[0]
        groupList.remove(at: 0)
        groupList.append(abcGroup)
        
        companyTableView.groupList = groupList
        companyTableView.separatorInset = .zero
        companyTableView.separatorStyle = .none
        companyTableView.allowsSelection = false

        companyTableView.layoutIfNeeded()
        companyTableView.reloadData()
    }
    
    func getHeight() -> CGFloat {
        print("title ", titleView.layer.height)
        print("content", companyTableView.contentSize.height)
        return titleView.layer.height + companyTableView.contentSize.height
    }
    
    @IBAction func onCardFilterChanged(_ sender: Any) {
//        if switchCard.isOn {
//            for company in companyList {
//                for item in tagList {
//                    if let compName = company.name {
//                        if item.title.equals(compName) {
//                            item.selected = company.recommend ?? false
//                        }
//                    }
//                }
//            }
//        } else {
//            for company in companyList {
//                for item in tagList {
//                    if (company.name == item.title){
//                        item.selected = company.is_visible
//                    }
//                }
//            }
//        }
//        updateSwitch()
//        allTagView.reloadData()
    }
    
    @IBAction func onSwitchValueChanged(_ sender: Any) {
//        for item in tagList {
//            item.selected = switchAll.isOn
//        }
//        updateSwitch()
//        switchCard.isOn = false
//        allTagView.reloadData()
    }
    
    func setUpUI(){
//        let layout = TagFlowLayout()
//        allTagView.collectionViewLayout = layout
//        allTagView.register(UINib(nibName: "TagListViewCell", bundle: nil), forCellWithReuseIdentifier: "tagListViewCell")
//        allTagView.delegate = self
//        allTagView.dataSource = self
//        allTagView.reloadData()
//        updateSwitch()
        
    }
    
    func updateSwitch() {
//        allSelect = true
//        for item in tagList {
//            if !item.selected {
//                allSelect = false
//            }
//        }
//        switchAll.setOn(allSelect, animated: true)
    }
    
    func resetFilter() {
//        for item in tagList {
//            item.selected = true
//        }
//        allTagView.reloadData()
//        switchAll.setOn(true, animated: true)
    }
    
    func applyFilter() {
//        for company in companyList {
//            for item in tagList {
//                if (company.name == item.title){
//                    if let companyId = company.company_id {
//                        ChargerManager.sharedInstance.updateCompanyVisibility(isVisible: item.selected, companyID: companyId)
//                        continue
//                    }
//                }
//            }
//        }
//        FilterManager.sharedInstance.updateCompanyFilter()
    }
    
    func isChanged() -> Bool {
        var changed = false
//        for company in companyList {
//            for item in tagList {
//                if (company.name == item.title){
//                    if (company.is_visible != item.selected){
//                        changed = true
//                        break
//                    }
//                }
//            }
//        }
        return changed
    }
}




//
//// MARK: - Delegate of Collection Cell
//extension FilterCompanyView : DelegateTagListViewCell{
//    func tagClicked(index: Int, value: Bool) {
//        // tag selected
//        tagList[index].selected = value
//        switchCard.isOn = false
//        updateSwitch()
//    }
//}
