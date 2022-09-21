//
//  EventViewController.swift
//  evInfra
//
//  Created by 이신광 on 06/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON
import RxSwift

internal final class EventViewController: UIViewController {

    // MARK: UI
    
    @IBOutlet weak var emptyView: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: VARIABLE
    
//    var list = Array<Event>()
    private var eventList: [AdsInfo] = [AdsInfo]()
    var displayedList : Set = Set<String>()
    internal var externalEventID: Int?
    internal var externalEventParam: String?
    
    private let disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        prepareTableView()
        
        getEventList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension EventViewController {
    
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "이벤트"
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
        tableView.tableFooterView = UIView()
        
        emptyView.isHidden = true
        tableView.isHidden = true
        indicator.isHidden = true
    }
    
    func indicatorControll(isStart:Bool) {
        if isStart {
            indicator.isHidden = false
            indicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            indicator.stopAnimating()
            indicator.isHidden = true
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    func updateTableView() {
        if self.eventList.count > 0 {
            self.emptyView.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        } else {
            self.emptyView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    func goToEventInfo(index: Int) {
        let event = eventList[index]
        let viewcon = NewEventDetailViewController()
        
        if event.evtType == Promotion.Types.event.toValue {
            MemberManager.shared.tryToLoginCheck { isLogin in
                if isLogin {
                    viewcon.eventUrl = event.extUrl
                    viewcon.queryItems = [URLQueryItem(name: "mbId", value: "\(MemberManager.shared.mbId)"),
                                          URLQueryItem(name: "promotionId", value: event.evtId)]
                    viewcon.naviTitle = event.evtTitle
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                } else {
                    MemberManager.shared.showLoginAlert()
                }
            }
        } else {
            viewcon.eventUrl = event.extUrl
            viewcon.naviTitle = event.evtTitle
            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
        }
    }
    
    @objc
    fileprivate func onClickBackBtn() {
        tableView.indexPathsForVisibleRows?.forEach({ IndexPath in
            if eventList[IndexPath.row].dpState == .inProgress {
                displayedList.insert(eventList[IndexPath.row].evtId)
            }
        })
        Server.countEventAction(eventId: Array(displayedList).map { String($0) }, action: .view, page: .event, layer: .list)
        self.navigationController?.pop()
    }
    
    private func logEventWithPromotion(index: Int) {
        Server.countEventAction(eventId: [String(eventList[index].evtId)], action: .click, page: .event, layer: .list)
        let property: [String: Any] = ["eventId": "\(eventList[index].evtId)",
                                       "eventName": "\(eventList[index].evtTitle)"]
        PromotionEvent.clickEvent.logEvent(property: property)
    }
}

extension EventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToEventInfo(index:indexPath.row)
        logEventWithPromotion(index: indexPath.row)
    }
}

extension EventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        let item = self.eventList[indexPath.row]
        cell.configure(item)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
//        let item = self.list[indexPath.row]
//        let imgurl: String = "\(Const.EV_PAY_SERVER)/assets/images/event/events/adapters/\(item.imagePath)"
//        if !imgurl.isEmpty {
//            cell.eventImageView.sd_setImage(with: URL(string: imgurl), placeholderImage: UIImage(named: "AppIcon"))
//        } else {
//            cell.eventImageView.image = UIImage(named: "AppIcon")
//            cell.eventImageView.contentMode = .scaleAspectFit
//        }
//
//        cell.eventCommentLabel.text = item.description
//        cell.eventEndDateLabel.text = "행사종료 : \(item.endDate)"
//
//        if item.state > Promotion.State.inProgress.toValue {
//            if item.state == Promotion.State.soldOut.toValue {
//                cell.eventStatusImageView.image = UIImage(named: "ic_event_soldout")
//            } else {
//                cell.eventStatusImageView.image = UIImage(named: "ic_event_end")
//            }
//            cell.isUserInteractionEnabled = false
//            cell.eventStatusView.isHidden = false
//            cell.eventStatusImageView.isHidden = false
//        } else {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            if let finishDate = formatter.date(from: item.endDate) {
//                let currentDate = Date()
//                if finishDate > currentDate {
//                    cell.isUserInteractionEnabled = true
//                    cell.eventStatusView.isHidden = true
//                    cell.eventStatusImageView.isHidden = true
//                } else {
//                    cell.isUserInteractionEnabled = false
//                    cell.eventStatusView.isHidden = false
//                    cell.eventStatusImageView.isHidden = false
//                    cell.eventStatusImageView.image = UIImage(named: "ic_event_end")
//                }
//            }
//        }
//
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tableView.indexPathsForVisibleRows?.forEach({ IndexPath in
            if eventList[IndexPath.row].dpState == .inProgress {
                displayedList.insert(eventList[IndexPath.row].evtId)
            }
        })
    }
}

extension EventViewController {
    func getEventList() {
        Server.getEventList(page: .event, layer: .list) { isSuccess, value in
            self.indicatorControll(isStart: true)
            if isSuccess {
                let json = JSON(value)
                let events = json["data"].arrayValue.map { AdsInfo($0) }
                
                guard !events.isEmpty else { return }
                self.eventList.removeAll()
                
                for event in events {
                    // TODO: externalEventID & externalEventParam 처리
                    if self.externalEventID == event.oldId {
                        guard let _externalEventParam = self.externalEventParam else { return }
                        let viewcon = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(ofType: EventContentsViewController.self)
                        viewcon.eventId = event.oldId
                        viewcon.eventTitle = event.evtTitle
                        viewcon.externalEventParam = _externalEventParam
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    }
                    
                    self.eventList.append(event)
                }
                
                self.eventList = self.eventList.sorted { $0.dpState.toValue < $1.dpState.toValue }
            } else {
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 이벤트 페이지 종료 후 재시도 바랍니다.")
            }
            self.updateTableView()
            self.indicatorControll(isStart: false)
        }
    }
//
//    func getEventList() {
//        indicatorControll(isStart: true)
//
//        Server.getEventList(page: .event, layer: .list) { (isSuccess, value) in
//            if isSuccess {
//                let json = JSON(value)
//                self.list.removeAll()
//
//                if json["code"].intValue != 1000 {
//                    self.updateTableView()
//                    self.indicatorControll(isStart: false)
//                } else {
//                    for jsonRow in json["list"].arrayValue {
//                        let item: Event = Event.init()
//
//                        item.eventId = jsonRow["id"].intValue
//                        item.eventType = jsonRow["type"].intValue
//                        item.standardValue  = jsonRow["strd_val"].intValue
//                        item.state = jsonRow["state"].intValue
//                        item.imagePath = jsonRow["image"].stringValue
//                        item.description = jsonRow["description"].stringValue
//                        item.endDate = jsonRow["finish_date"].stringValue
//                        item.title = jsonRow["title"].stringValue
//
//                        if self.externalEventID == item.eventId {
//                            guard let _externalEventParam = self.externalEventParam else {
//                                return
//                            }
//                            EIAdManager.sharedInstance.logEvent(eventId: [String(item.eventId)], action: Promotion.Action.click)
//                            let viewcon = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(ofType: EventContentsViewController.self)
//                            viewcon.eventId = item.eventId
//                            viewcon.eventTitle = item.title
//                            viewcon.externalEventParam = _externalEventParam
//                            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
//                        }
//
//                        if (item.state == 0) {
//                            let formatter = DateFormatter()
//                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                            if let finishDate = formatter.date(from: item.endDate) {
//                                let currentDate = Date()
//                                if finishDate <= currentDate {
//                                    item.state = self.EVENT_END
//                                }
//                            }
//                        }
//                        self.list.append(item)
//                    }
//                    self.list = self.list.sorted(by: {$0.state < $1.state})
//                }
//
//
//                self.updateTableView()
//                self.indicatorControll(isStart: false)
//            } else {
//                self.updateTableView()
//                self.indicatorControll(isStart: false)
//                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 이벤트 페이지 종료 후 재시도 바랍니다.")
//            }
//        }
//    }
}

