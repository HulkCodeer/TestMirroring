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

internal final class EventViewController: CommonBaseViewController {

    // MARK: UI
    
    @IBOutlet weak var emptyView: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var commonNaviView = CommonNaviView().then {
        $0.naviTitleLbl.text = "이벤트"
    }
    
    // MARK: VARIABLE
    
    private var eventList: [AdsInfo] = [AdsInfo]()
    private var displayedList : Set = Set<String>()
    internal var externalEventID: Int?
    internal var externalEventParam: String?
    
    private let disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        contentView.addSubview(commonNaviView)
        commonNaviView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        commonNaviView.backClosure = { [weak self] in
            guard let self = self else { return }
            self.tableView.indexPathsForVisibleRows?.forEach({ IndexPath in
                if self.eventList[IndexPath.row].dpState == .inProgress {
                    self.displayedList.insert(self.eventList[IndexPath.row].evtId)
                }
            })
            Server.countEventAction(eventId: Array(self.displayedList).map { String($0) }, action: .view, page: .event, layer: .list)
            GlobalDefine.shared.mainNavi?.pop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        getEventList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: FUNC
    
    private func getEventList() {
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
    
    private func prepareTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
        tableView.tableFooterView = UIView()
    }
    
    private func indicatorControll(isStart: Bool) {
        indicator.isHidden = !isStart
        if isStart {
            indicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            indicator.stopAnimating()        
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    private func updateTableView() {
        if self.eventList.count > 0 {
            self.emptyView.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()

//            UserDefault().saveInt(key: UserDefault.Key.LAST_EVENT_ID, value: eventList[0].evtId)
        } else {
            self.emptyView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    private func goToEventInfo(index: Int) {
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
