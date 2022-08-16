//
//  File.swift
//  evInfra
//
//  Created by 박현진 on 2022/08/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

extension UITableView {
    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, for indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseID, for: indexPath) as? T else {
            fatalError("error: dequeueReusableCell")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T>(ofType cellType: T.Type = T.self) -> T where T: UITableViewHeaderFooterView {
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: cellType.reuseID) as? T else {
            fatalError("error: dequeueReusableCell")
        }
        return cell
    }
    
    func reloadDataWithCompletion(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
            { _ in completion() }
    }
    
    func hasRow(at indexPath: IndexPath) -> Bool {
        indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

extension UITableViewCell: Reusable {}

extension UITableViewHeaderFooterView: Reusable {}
