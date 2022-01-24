//
//  BoardTableView.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 16..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class BoardTableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    public static let PAGE_DATA_COUNT = 20
    
    // 선택한 충전소 게시판 종류
    public static let SELECT_STATION_BOARD  = 1
    public static let FREE_BOARD            = 2
    public static let STATION_BOARD         = 3
    
    var boardList: Array<BoardItem>!
    
    var tableViewDelegate: BoardTableViewDelegate?
    
    var category:String = Board.CommunityType.FREE.rawValue
    
    var isLastPage:Bool = false
    var isRefresh:Bool = false
    
    var currentPage = 0
    var mode = 0
    
    var sectionHeightsDictionary: [Int: CGFloat] = [:]

    var communityBoardList: [BoardListItem] = [BoardListItem]()
    var sortType: Board.SortType = .LATEST
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        self.allowsSelection = true
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        self.separatorStyle = .none
        self.register(UINib(nibName: "CommunityBoardTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "CommunityBoardTableViewHeader")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.communityBoardList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewDelegate?.didSelectItem()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch category {
        case Board.CommunityType.FREE.rawValue,
            Board.CommunityType.CORP_GS.rawValue,
            Board.CommunityType.CORP_JEV.rawValue,
            Board.CommunityType.CORP_STC.rawValue,
            Board.CommunityType.CORP_SBC.rawValue:
            guard let cell = Bundle.main.loadNibNamed("CommunityBoardTableViewCell", owner: self, options: nil)?.first as? CommunityBoardTableViewCell else { return UITableViewCell() }
            
            cell.configure(item: communityBoardList[indexPath.row])
            cell.selectionStyle = .none
            
            return cell
        case Board.CommunityType.CHARGER.rawValue:
            guard let cell = Bundle.main.loadNibNamed("CommunityChargeStationTableViewCell", owner: self, options: nil)?.first as? CommunityChargeStationTableViewCell else { return UITableViewCell() }
            
            cell.configure(item: communityBoardList[indexPath.row])
            cell.selectionStyle = .none
            
            return cell
        default:
            return UITableViewCell()
        }

//
//        let cell = Bundle.main.loadNibNamed("BoardTableViewCell", owner: self, options: nil)?.first as! BoardTableViewCell
////        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardTableViewCell", for: indexPath) as! BoardTableViewCell
//
//        let replyValue = self.boardList[indexPath.section].reply![indexPath.row]
//
//        // 지킴이 표시
//        if replyValue.mbLevel == MemberManager.MB_LEVEL_GUARD {
//            cell.rUserGuardIcon.visible()
//            cell.rUserGuardLabel.visible()
//        } else {
//            cell.rUserGuardIcon.gone()
//            cell.rUserGuardLabel.gone()
//        }
//
//        cell.rUserName?.text = replyValue.nick
//        cell.rDate?.text = Date().toStringToMinute(data: replyValue.date!)
//        //replyValue["rdate"].stringValue.components(separatedBy: "T")[0]
//        cell.rContents?.text = replyValue.content
//
//        if let cType = replyValue.chargerType, !cType.isEmpty {
//            cell.rChargerType.visible()
//            cell.rChargerType.text = cType
//        } else {
//            cell.rChargerType.gone()
//        }
//        if (MemberManager.getMbId() > 0) && (MemberManager.getMbId() == replyValue.mbId)  {
//            cell.rEditBtn.visible()
//            cell.rDeleteBtn.visible()
//            cell.rEditBtn.tag = (indexPath.section * 1000) + indexPath.row
//            cell.rDeleteBtn.tag =  (indexPath.section * 1000) + indexPath.row
//            cell.rEditBtn.addTarget(self, action: #selector(self.onClickReplyEdit(_:)), for: .touchUpInside)
//            cell.rDeleteBtn.addTarget(self, action: #selector(self.onClickReplyDelete(_:)), for: .touchUpInside)
//        } else {
//            cell.rEditBtn.gone()
//            cell.rDeleteBtn.gone()
//        }
//
//        if replyValue.profile_img != nil {
//            cell.rUserImage.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(replyValue.profile_img!)"), placeholderImage: UIImage(named: "ic_person_base36"))
//        } else {
//            cell.rUserImage.image = UIImage(named: "ic_person_base36")
//            cell.rUserImage.contentMode = .scaleAspectFit
//        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        if let height =  sectionHeightsDictionary[section] {
//            return height
//        }
//
//        let headerValue = self.boardList[section]
//        if headerValue.content_img == nil || headerValue.content_img!.isEmpty {
//            return 134
//        } else {
//            return 370
//        }
        return 370
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
//        return 16
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        sectionHeightsDictionary[section] = view.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
//        guard let headerView = Bundle.main.loadNibNamed("CommunityBoardTableViewHeader", owner: self, options: nil)?.first as? CommunityBoardTableViewHeader else { return UIView() }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommunityBoardTableViewHeader") as! CommunityBoardTableViewHeader
        
        headerView.setupBannerView(categoryType: category)
        headerView.delegate = self
        
        return headerView
    }
 
    /*
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("BoardTableViewHeader", owner: self, options: nil)?.first as! BoardTableViewHeader
//        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BoardTableViewHeader") as! BoardTableViewHeader
        
        let headerValue = self.boardList[section]
        
        // 충전소 게시판의 경우 충전소 바로가기 버튼
        if category.elementsEqual(Board.BOARD_CATEGORY_CHARGER) {
            if headerValue.adId < 1 {
                headerView.uGoCharger.visible()
                headerView.uGoCharger.tag =  section
                headerView.uGoCharger.addTarget(self, action: #selector(self.onClickStation(_:)), for: .touchUpInside)
            } else { // 광고글인 경우 충전소 바로가기 버튼 제거
                headerView.uGoCharger.gone()
            }
        } else {
            headerView.uGoCharger.gone()
        }
        
        // 지킴이 표시
        if headerValue.mbLevel == MemberManager.MB_LEVEL_GUARD {
            headerView.userGuardIcon.visible()
            headerView.userGuardLabel.visible()
        } else {
            headerView.userGuardIcon.gone()
            headerView.userGuardLabel.gone()
        }
        
        if headerValue.content_img == nil || headerValue.content_img!.isEmpty {
            headerView.uImage.gone()
        } else {
            headerView.uImage.visible()
            if headerValue.adId > 0 {
                let adTab = UITapGestureRecognizer(target: self, action: #selector(onClickAdImage(sender:)))
                
                headerView.uImage.tag = section
                headerView.uImage.sd_setImage(with: URL(string: "\(Const.EI_IMG_SERVER)\(headerValue.content_img!)"), placeholderImage: UIImage(named: "placeholder.png"))
                headerView.uImage.isUserInteractionEnabled = true
                headerView.uImage.addGestureRecognizer(adTab)
            } else {
                headerView.uImage.sd_setImage(with: URL(string: "\(Const.urlBoardImage)\(headerValue.content_img!).jpg"), placeholderImage: UIImage(named: "placeholder.png"))
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
                headerView.uImage.isUserInteractionEnabled = true
                headerView.uImage.addGestureRecognizer(tapGestureRecognizer)
            }
        }

        if (MemberManager.getMbId() > 0) && (MemberManager.getMbId() == headerValue.mbId) {
            headerView.uEditBtn.visible()
            headerView.uDeletBtn.visible()
            headerView.uEditBtn.tag = section
            headerView.uDeletBtn.tag = section
            headerView.uEditBtn.addTarget(self, action: #selector(self.onClickBoardEdit(_:)), for: .touchUpInside)
            headerView.uDeletBtn.addTarget(self, action: #selector(self.onClickBoardDelete(_:)), for: .touchUpInside)
        } else {
            headerView.uEditBtn.gone()
            headerView.uDeletBtn.gone()
        }
        
        headerView.userName?.text = headerValue.nick
        
        if headerValue.adId > 0 {
            headerView.uDate?.text = "advertisement"
            headerView.uReplyBtn.gone()
        } else {
            headerView.uDate?.text = Date().toStringToMinute(data: headerValue.date!)
            headerView.uReplyBtn.tag =  self.boardList[section].boardId!
            headerView.uReplyBtn.addTarget(self, action: #selector(self.onClickReply(_:)), for: .touchUpInside)
        }
        
        if headerValue.stationName != nil && self.category.elementsEqual(Board.BOARD_CATEGORY_CHARGER) {
            headerView.uText?.text = "[\(headerValue.stationName!)]\n\(headerValue.content!)"
        } else {
            headerView.uText?.text = headerValue.content
        }
        
        if headerValue.profile_img != nil {
            if (headerValue.adId > 0) {
                headerView.userImageView.sd_setImage(with: URL(string: "\(Const.EI_IMG_SERVER)\(headerValue.profile_img!)"), placeholderImage: UIImage(named: "ic_person_base48"))
            } else {
                headerView.userImageView.sd_setImage(with: URL(string: "\(Const.urlProfileImage)\(headerValue.profile_img!)"), placeholderImage: UIImage(named: "ic_person_base48"))
            }
        } else {
            headerView.userImageView.image = UIImage(named: "ic_person_base48")
            headerView.userImageView.contentMode = .scaleAspectFit
        }
        
        if let reply = headerValue.reply {
            if reply.count > 0 {
                headerView.uReplyCnt.text = "댓글(\(reply.count))"
            } else {
                headerView.uReplyCnt.text = ""
            }
        }
        
        if let cType = headerValue.chargerType, !cType.isEmpty {
            headerView.uChargerType.visible()
            headerView.uChargerType.text = cType
        } else {
            headerView.uChargerType.gone()
        }

        return headerView
    }
    */
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView =  Bundle.main.loadNibNamed("BoardTableViewFooter", owner: self, options: nil)?.first as! BoardTableViewFooter
//        footerView.footerView.layer.shadowColor = UIColor.black.cgColor
//        footerView.footerView.layer.shadowOpacity = 0.5
//        footerView.footerView.layer.shadowOffset = CGSize(width: 0, height: -1)
//
//        return footerView
//    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maximumOffset - currentOffset <= -20.0 {
            self.tableViewDelegate?.fetchNextBoard(mid: category, sort: sortType)
        }
    }

    // MARK: - For Communication Data For Server

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK: - Action for button
    /*
    @objc func onClickBoardEdit(_ sender: UIButton) {
        tableViewDelegate?.boardEdit(tag: sender.tag)
    }
    
    @objc func onClickBoardDelete(_ sender: UIButton) {
        print("DELETE BUTTON CLICK \(sender.tag)")
        tableViewDelegate?.boardDelete(tag: sender.tag)
    }
    
    @objc func onClickReplyEdit(_ sender: UIButton) {
        print("Reply EDIT BUTTON CLICK \(sender.tag)")
        tableViewDelegate?.replyEdit(tag: sender.tag)
    }
    
    @objc func onClickReplyDelete(_ sender: UIButton) {
        tableViewDelegate?.replyDelete(tag: sender.tag)
    }
    
    @objc func onClickReply(_ sender: UIButton) {
        print("Reply BUTTON CLICK \(sender.tag)")
        tableViewDelegate?.makeReply(tag: sender.tag)
    }

    @objc func onClickStation(_ sender: UIButton) {
        print("Station BUTTON CLICK \(sender.tag)")
        tableViewDelegate?.goToStation(tag: sender.tag)
    }
     */
    /*
    @objc func onClickAdImage(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let view = sender.view {
                if let urlString = boardList[view.tag].adUrl {
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url, options: [:])
                        
                        // 광고 click event 전송
                        Server.countAdAction(adId: boardList[view.tag].adId, action: EIAdManager.ACTION_CLICK)
                    }
                }
            }
        }
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
            
        tableViewDelegate?.showImageViewer(url: tappedImage.sd_imageURL()!);
    }
     */
}

 // MARK: - Header Delegate
extension BoardTableView: CommunityBoardTableViewHeaderDelegate {
    func didSelectTag(_ selectedType: Board.SortType) {
        sortType = selectedType
        self.tableViewDelegate?.fetchFirstBoard(mid: self.category, sort: self.sortType)
    }
}
