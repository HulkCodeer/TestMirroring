//
//  BoardTableViewDelegate.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

protocol BoardTableViewDelegate {

    // MARK: - 커뮤니티 개선 delegate
    func fetchFirstBoard(mid: String, sort: Board.SortType, mode: String)
    func fetchNextBoard(mid: String, sort: Board.SortType, mode: String)
    func didSelectItem(at: Int)
    func showImageViewer(url: URL)
}

