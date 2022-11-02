//
//  NewCompanyTableView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/28.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

internal final class NewCompanyTableView: UITableView {
    // MARK: VARIABLES
    internal var groups: [NewCompanyGroup] = [NewCompanyGroup]()
    
    // MARK: SYSTEM FUNC
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
//
//extension NewCompanyTableView: UITableViewDelegate {
//
//}
//
//extension NewCompanyTableView: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewCompanyTableViewCell", for: indexPath) as? NewCompanyTableViewCell else { return UITableViewCell() }
//        cell.groupTitleLbl.text = groups[indexPath.row].groupTitle
//        return cell
//    }
//}
