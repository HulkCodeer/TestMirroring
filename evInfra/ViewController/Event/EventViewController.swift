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
    
    var list: [AdsInfo] = [AdsInfo]()
    var displayedList: Set = Set<String>()
    internal var externalEventID: String?
    internal var externalEventParam: String?
    
    enum EventStatus: Int {
        case end = 0
        case inprogress = 1
    }
    
    private let disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "이벤트 리스트 화면"
        prepareActionBar()
        prepareTableView()
        
        getEvents()
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
        if self.list.count > 0 {
            self.emptyView.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()

            UserDefault().saveString(key: UserDefault.Key.LAST_EVENT_ID, value: list[0].evtId)
        } else {
            self.emptyView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    func goToEventInfo(index: Int) {
        RestApi().countEventAction(eventId: [String(list[index].eventId)], action: EIAdManager.EventAction.click.rawValue)
            .disposed(by: self.disposebag)

        let viewcon = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(ofType: EventContentsViewController.self)
        viewcon.eventId = list[index].evtId
        viewcon.eventTitle = list[index].evtTitle
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
    
    @objc
    fileprivate func onClickBackBtn() {
        tableView.indexPathsForVisibleRows?.forEach({ IndexPath in
            if list[IndexPath.row].dpState == EventStatus.inprogress.rawValue {
                displayedList.insert(list[IndexPath.row].evtId)
            }
        })
        
        let displatedList = displayedList.map { String($0) }        
        RestApi().countEventAction(eventId: displatedList, action: EIAdManager.EventAction.view.rawValue)
            .disposed(by: self.disposebag)
        self.navigationController?.pop()
    }
}

extension EventViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToEventInfo(index:indexPath.row)
    }
}

extension EventViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        let item = self.list[indexPath.row]
        let imageUrl: String = "\(Const.AWS_SERVER)/image/\(item.img)"
        if !imageUrl.isEmpty {
            cell.eventImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "AppIcon"))
        } else {
            cell.eventImageView.image = UIImage(named: "AppIcon")
            cell.eventImageView.contentMode = .scaleAspectFit
        }
        
        cell.eventCommentLabel.text = item.evtDesc
        cell.eventEndDateLabel.text = "행사종료 : \(item.dpEnd)"
        
        if item.dpState == EventStatus.end.rawValue {
            cell.isUserInteractionEnabled = false
            cell.eventStatusView.isHidden = false
            cell.eventStatusImageView.isHidden = false
            cell.eventStatusImageView.image = UIImage(named: "ic_event_end")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let finishDate = formatter.date(from: item.dpEnd) {
                let currentDate = Date()
                if finishDate > currentDate {
                    cell.isUserInteractionEnabled = true
                    cell.eventStatusView.isHidden = true
                    cell.eventStatusImageView.isHidden = true
                } else {
                    cell.isUserInteractionEnabled = false
                    cell.eventStatusView.isHidden = false
                    cell.eventStatusImageView.isHidden = false
                    cell.eventStatusImageView.image = UIImage(named: "ic_event_end")
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tableView.indexPathsForVisibleRows?.forEach({ IndexPath in
            if list[IndexPath.row].dpState == EventStatus.inprogress.rawValue {
                displayedList.insert(list[IndexPath.row].evtId)
            }
        })
    }
}

extension EventViewController {
    
    private func getEvents() {
        indicatorControll(isStart: true)
        
        EIAdManager.sharedInstance.getAdsList(page: Promotion.Page.event, layer: Promotion.Layer.list) { adsList in
            defer {
                self.updateTableView()
                self.indicatorControll(isStart: false)
            }
            
            adsList.forEach {
                var _ad: AdsInfo = $0
                
                if self.externalEventID == _ad.evtId {
                    guard let _externalEventParam = self.externalEventParam else {
                        return
                    }
                    EIAdManager.sharedInstance.logEvent(adIds: [_ad.evtId], action: Promotion.Action.click, page: Promotion.Page.event, layer: nil)
                    
                    let viewcon = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(ofType: EventContentsViewController.self)
                    viewcon.eventId = _ad.evtId
                    viewcon.eventTitle = _ad.evtTitle
                    viewcon.externalEventParam = _externalEventParam
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                }
                
                if _ad.dpState == 0 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let finishDate = formatter.date(from: _ad.dpEnd) {
                        let currentDate = Date()
                        if finishDate <= currentDate {
                            _ad.dpState = EventStatus.end.rawValue
                        }
                    }
                }
                self.list.append(_ad)
            }
            self.list = self.list.sorted(by: {$0.dpState < $1.dpState})
        }
    }
    /*
    func getEventList() {
        indicatorControll(isStart: true)
        
        Server.getEventList { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                self.list.removeAll()
                
                if json["code"].intValue != 1000 {
                    self.updateTableView()
                    self.indicatorControll(isStart: false)
                } else {
                    for jsonRow in json["list"].arrayValue {
                        let item: Event = Event.init()
                        
                        item.eventId = jsonRow["id"].intValue
                        item.eventType = jsonRow["type"].intValue
                        item.standardValue  = jsonRow["strd_val"].intValue
                        item.state = jsonRow["state"].intValue
                        item.imagePath = jsonRow["image"].stringValue
                        item.description = jsonRow["description"].stringValue
                        item.endDate = jsonRow["finish_date"].stringValue
                        item.title = jsonRow["title"].stringValue
                        
                        if self.externalEventID == item.eventId {
                            guard let _externalEventParam = self.externalEventParam else {
                                return
                            }                            
                            RestApi().countEventAction(eventId: [String(item.eventId)], action: EIAdManager.EventAction.click.rawValue)
                                .disposed(by: self.disposebag)
                            let viewcon = UIStoryboard(name: "Event", bundle: nil).instantiateViewController(ofType: EventContentsViewController.self)
                            viewcon.eventId = item.eventId
                            viewcon.eventTitle = item.title
                            viewcon.externalEventParam = _externalEventParam
                            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                        }
                        
                        if (item.state == 0) {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            if let finishDate = formatter.date(from: item.endDate) {
                                let currentDate = Date()
                                if finishDate <= currentDate {
                                    item.state = self.EVENT_END
                                }
                            }
                        }
                        self.list.append(item)
                    }
                    self.list = self.list.sorted(by: {$0.state < $1.state})
                }
                
                self.updateTableView()
                self.indicatorControll(isStart: false)
            } else {
                self.updateTableView()
                self.indicatorControll(isStart: false)
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 이벤트 페이지 종료 후 재시도 바랍니다.")
            }
        }
    }
     */
}
