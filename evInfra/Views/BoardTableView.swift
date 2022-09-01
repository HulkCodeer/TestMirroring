//
//  BoardTableView.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 16..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

class BoardTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    weak var tableViewDelegate: BoardTableViewDelegate?
    var category: Board.CommunityType = .FREE
    var isLastPage: Bool = false
    var isRefresh: Bool = false
    var currentPage = 0
    var communityBoardList: [BoardListItem] = [BoardListItem]()
    var sortType: Board.SortType = .LATEST
    var screenType: Board.ScreenType = .LIST
    var isNoneHeader: Bool = false
    var isFromDetailView: Bool = false
    var adIndex: Int = -1
    private var adminList: [Admin] = [Admin]()
    internal var viewedCnt: Int = 0
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configuration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configuration()
    }
    
    private func configuration() {
        self.dataSource = self
        self.delegate = self
        self.allowsSelection = true
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        self.separatorStyle = .none
        self.register(UINib(nibName: "CommunityBoardTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "CommunityBoardTableViewHeader")
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        
        getAdminList { adminList in
            self.adminList = adminList
        }
    }
    
    private func getAdminList(completion: @escaping ([Admin]) -> Void) {
        Server.getAdminList { (isSuccess, data) in
            guard let data = data as? Data else { return }
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode([Admin].self, from: data)
                completion(result)
            } catch {
                completion([])
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return communityBoardList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isAd = communityBoardList[indexPath.row].board_id?.contains("ad") ?? false
        if !isAd {
            tableViewDelegate?.didSelectItem(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let isAd = communityBoardList[indexPath.row].board_id?.contains("ad") ?? false
        
        switch category {
        case .FREE, .CORP_GS, .CORP_JEV, .CORP_STC, .CORP_SBC:
            if isAd {
                guard let adCell = Bundle.main.loadNibNamed("CommunityBoardAdsCell", owner: self, options: nil)?.first as? CommunityBoardAdsCell else { return UITableViewCell() }
                
                adCell.selectionStyle = .none
                adCell.configuration(item: communityBoardList[indexPath.row])
                
                return adCell
            } else {
                guard let cell = Bundle.main.loadNibNamed("CommunityBoardTableViewCell", owner: self, options: nil)?.first as? CommunityBoardTableViewCell else { return UITableViewCell() }
                
                viewedCnt += 1
                cell.selectionStyle = .none
                cell.adminList = adminList
                cell.configure(item: communityBoardList[indexPath.row])
                cell.imageTapped = { [weak self] imageUrl in
                    self?.tableViewDelegate?.showImageViewer(url: imageUrl, isProfileImageMode: true)
                }
                
                return cell
            }
        case .CHARGER:
            
            if isAd {
                guard let adCell = Bundle.main.loadNibNamed("CommunityBoardAdsCell", owner: self, options: nil)?.first as? CommunityBoardAdsCell else { return UITableViewCell() }
                
                adCell.selectionStyle = .none
                adCell.configuration(item: communityBoardList[indexPath.row])

                return adCell
            } else {
                guard let cell = Bundle.main.loadNibNamed("CommunityChargeStationTableViewCell", owner: self, options: nil)?.first as? CommunityChargeStationTableViewCell else { return UITableViewCell() }
                
                viewedCnt += 1
                cell.selectionStyle = .none
                cell.adminList = adminList
                cell.isFromDetailView = isFromDetailView
                cell.configure(item: communityBoardList[indexPath.row])
                cell.chargeStataionButtonTappedCompletion = { chargerId in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "showSelectCharger"), object: chargerId)
                    GlobalDefine.shared.mainNavi?.popToMain()
                }
                cell.imageTapped = { [weak self] imageUrl in
                    self?.tableViewDelegate?.showImageViewer(url: imageUrl, isProfileImageMode: true)
                }
                
                return cell
            }
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 370
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if isNoneHeader {
            return nil
        } else {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommunityBoardTableViewHeader") as? CommunityBoardTableViewHeader else { return UIView() }
            
            if #available(iOS 14.0, *) {
                headerView.backgroundConfiguration?.backgroundColor = UIColor(named: "nt-white")
            }

            headerView.configuration(with: category)
            headerView.delegate = self
            
            return headerView
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maximumOffset - currentOffset <= -20.0 {
            self.tableViewDelegate?.fetchNextBoard(mid: self.category.rawValue, sort: self.sortType, mode: self.screenType.rawValue)
        }
    }
}

 // MARK: - Header Delegate
extension BoardTableView: CommunityBoardTableViewHeaderDelegate {
    func didSelectTag(_ selectedType: Board.SortType) {
        sortType = selectedType
        self.tableViewDelegate?.fetchFirstBoard(mid: self.category.rawValue, sort: self.sortType, mode: self.screenType.rawValue)
    }
}
