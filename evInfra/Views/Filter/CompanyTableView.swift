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

protocol CompanyTableDelegate: AnyObject {
    func onClickTag(tagName: String, value: Bool)
}

class CompanyTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var groupList: Array<CompanyGroup>!
    internal weak var tableDelegate: CompanyTableDelegate?
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
        cell.delegate = self
        let height = cell.tagView.collectionViewLayout.collectionViewContentSize.height + 50
        cell.bounds.size.height = height
        cell.layoutIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = Bundle.main.loadNibNamed("CompanyTableViewCell", owner: self, options: nil)?.first as! CompanyTableViewCell
        cell.tagList = groupList[indexPath.row].list
        cell.tagView.reloadData()
        cell.layoutIfNeeded()
        var height: CGFloat = 32 * CGFloat(cell.rowCounts) + 48
        if (cell.rowCounts > 1) {
            height -= 8
        }
        return CGFloat(height)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension CompanyTableView: CompanyTableCellDelegate {
    func onClickTag(tagName: String, value: Bool, groupIndex: Int) {
        if let delegate = self.tableDelegate {
            delegate.onClickTag(tagName: tagName, value: value)
        }
    }
}
