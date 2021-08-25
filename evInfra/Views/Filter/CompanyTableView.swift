//
//  CompanyTableView.swift
//  evInfra
//
//  Created by SH on 2021/08/24.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit

class CompanyGroup {
    var title: String!
    var list: Array<TagValue>!
    
    public init(title: String, list: Array<TagValue>) {
        self.title = title
        self.list = list
    }
}

class CompanyTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var groupList : Array<CompanyGroup>!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.separatorStyle = .none
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.groupList == nil {
            return 0
        }
        
        return self.groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CompanyTableViewCell", owner: self, options: nil)?.first as! CompanyTableViewCell
        cell.groupTitle.text = groupList[indexPath.row].title
        cell.tagList = groupList[indexPath.row].list
        cell.tagView.reloadData()
        let height = cell.tagView.collectionViewLayout.collectionViewContentSize.height + 50
        cell.bounds.size.height = height
        cell.layoutIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
