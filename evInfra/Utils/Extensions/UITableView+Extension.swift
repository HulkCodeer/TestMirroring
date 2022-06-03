//
//  UITableView+Extension.swift
//  evInfra
//
//  Created by 박현진 on 2022/06/03.
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
}

extension UITableViewCell: Reusable {}
