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
    
    private let GROUP_TITLE = ["A.B.C..", "가", "나", "다", "라", "마", "바", "사", "아", "자", "차", "카", "타", "파", "하", "힣"];

    var companyList = [CompanyInfoDto]()
    var groupList = Array<CompanyGroup>()
    
    var allSelect: Bool = false
    var cardSetting: Bool = false
    
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
        allSelect = true
        var tagList = Array<TagValue>()
        var recommendList = Array<TagValue>()
        var titleIndex = 1
        companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
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
                    
                    var selected = company.is_visible
                    if cardSetting {
                        selected = company.card_setting ?? false // infra card
                    }
                    let tag = TagValue(title:company.name!, img:icon, selected: selected)
                    tagList.append(tag)
                    if company.recommend ?? false {
                        recommendList.append(tag)
                    }

                    if !selected {
                        allSelect = false
                    }
                }
            }
        }
        switchAll.isOn = allSelect
        
        if !tagList.isEmpty {
            groupList.append(CompanyGroup(title: GROUP_TITLE[titleIndex-1], list: tagList))
        }

        let abcGroup = groupList[0]
        groupList.remove(at: 0)
        groupList.append(abcGroup)
        
        groupList.insert(CompanyGroup(title: "추천", list: recommendList), at: 0)
    }
    
    func setUpUI(){
        companyTableView.separatorInset = .zero
        companyTableView.separatorStyle = .none
        companyTableView.allowsSelection = false
        companyTableView.tableDelegate = self
        
        updateTable()
    }
    
    func updateTable() {
        companyTableView.groupList = groupList
        companyTableView.reloadData()
        companyTableView.layoutIfNeeded()
    }

    func getHeight() -> CGFloat {
        return titleView.layer.height + companyTableView.contentSize.height
    }
    
    @IBAction func onCardFilterChanged(_ sender: Any) {
        cardSetting = switchCard.isOn
        prepareTagList()
        setUpUI()
    }
    
    @IBAction func onSwitchValueChanged(_ sender: Any) {
        for list in groupList {
            for tag in list.list {
                tag.selected = switchAll.isOn
            }
        }
        switchCard.isOn = false
        allSelect = switchAll.isOn
        setUpUI()
    }
    
    func updateSwitch() {
        allSelect = true
        for list in groupList {
            for tag in list.list {
                if tag.selected != true {
                    allSelect = false
                }
            }
        }
        switchAll.setOn(allSelect, animated: true)
    }
    
    func resetFilter() {
        for list in groupList {
            for tag in list.list {
                tag.selected = true
            }
        }
        
        switchAll.setOn(true, animated: true)
        switchCard.setOn(false, animated: true)
        setUpUI()
    }
    
    func applyFilter() {
        for company in companyList {
            for list in groupList {
                for tag in list.list {
                    if (company.name == tag.title){
                        if let companyId = company.company_id {
                            ChargerManager.sharedInstance.updateCompanyVisibility(isVisible: tag.selected, companyID: companyId)
                            continue
                        }
                    }
                }
            }
        }
        FilterManager.sharedInstance.updateCompanyFilter()
    }
    
    func isChanged() -> Bool {
        var changed = false
        for company in companyList {
            for list in groupList {
                for tag in list.list {
                    if (company.name == tag.title){
                        if (company.is_visible != tag.selected){
                            changed = true
                            return changed
                        }
                    }
                }
            }
        }
        return changed
    }
}


extension FilterCompanyView : CompanyTableDelegate{
    func onClickTag(tagName: String, value: Bool) {
        var changed = false
        // tag selected
        for list in groupList {
            for tag in list.list {
                if tag.title == tagName {
                    tag.selected = value
                    changed = true
                }
            }
        }
        if changed {
            updateTable()
        }
    }
}
