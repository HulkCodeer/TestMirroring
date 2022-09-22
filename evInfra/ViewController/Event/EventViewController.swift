//
//  EventViewController.swift
//  evInfra
//
//  Created by 이신광 on 06/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift
import RxCocoa

internal final class EventViewController: UIViewController {

    // MARK: UI
    
    @IBOutlet weak var naviTitle: UILabel!
    @IBOutlet weak var naviBackBtn: UIButton!
    @IBOutlet weak var commonNaviView: UIView!
    @IBOutlet weak var emptyView: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    

    // MARK: VARIABLE
    
    private var eventList: [AdsInfo] = [AdsInfo]()
    private var displayedList : Set = Set<String>()
    internal var externalEventID: Int?
    internal var externalEventParam: String?
    
    private let disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviTitle.text = "이벤트"
        naviBackBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                obj.tableView.indexPathsForVisibleRows?.forEach({ IndexPath in
                    if obj.eventList[IndexPath.row].dpState == .inProgress {
                        obj.displayedList.insert(self.eventList[IndexPath.row].evtId)
                    }
                })
                Server.countEventAction(eventId: Array(self.displayedList).map { String($0) }, action: .view, page: .event, layer: .list)
                GlobalDefine.shared.mainNavi?.pop()
            }
            .disposed(by: self.disposebag)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
        tableView.tableFooterView = UIView()
        
        getEventList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
    
    // MARK: FUNC
    
    private func getEventList() {
        self.indicatorControll(isStart: true)
        RestApi().getAdsList(page: .event, layer: .list)
                .convertData()
                .compactMap { result -> [AdsInfo]? in
                    switch result {
                    case .success(let data):
                        let json = JSON(data)
                        let events = json["data"].arrayValue.map { AdsInfo($0) }
                        printLog(out: "PARK TEST events : \(events)")
                        guard !events.isEmpty else { return [] }
                        return events
                        
                    case .failure(let errorMessage):
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 이벤트 페이지 종료 후 재시도 바랍니다.")
                        printLog(out: "Error Message : \(errorMessage)")
                        return []
                    }
                }
                .subscribe(onNext: { [weak self] adList in
                    guard let self = self else { return }
                    self.eventList.removeAll()
                    
                    for event in adList {
                        // TODO: externalEventID & externalEventParam 처리
                        if self.externalEventID == event.oldId {
                            guard let _externalEventParam = self.externalEventParam else { return }
                            let viewcon = NewEventDetailViewController()
                            viewcon.eventData = EventData(eventUrl: event.extUrl)
                            
                            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                        }
                        
                        self.eventList.append(event)
                    }
                    
                    self.eventList = self.eventList.sorted { $0.dpState.toValue < $1.dpState.toValue }
                    self.updateTableView()
                    
                })
                .disposed(by: self.disposebag)
        self.indicatorControll(isStart: false)
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
        
        switch event.convertEvtType {
        case .event:
            MemberManager.shared.tryToLoginCheck { isLogin in
                if isLogin {
                    viewcon.eventData = EventData(naviTitle: event.evtTitle, eventUrl: event.extUrl, promotionId: event.evtId, mbId: MemberManager.shared.mbIdToStr)
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                } else {
                    MemberManager.shared.showLoginAlert()
                }
            }
            
        default:            
            viewcon.eventData = EventData(naviTitle: event.evtTitle, eventUrl: event.extUrl)
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
