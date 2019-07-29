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

class EventViewController: UIViewController {

    private let EVENT_IN_PROGRESS = 0
    private let EVENT_SOLD_OUT = 1
    private let EVENT_END = 2
    
    @IBOutlet weak var emptyView: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var list = Array<Event>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        
        prepareTableView()
        
        getEventList()
    }
}


extension EventViewController {
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "이벤트"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor(rgb: 0xE4E4E4)
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
          
            let defaults = UserDefault()
            defaults.saveInt(key: UserDefault.Key.LAST_EVENT_ID, value: list[0].eventId)
        } else {
            self.emptyView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    func  goToEventInfo(index: Int) {
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "EventContentsViewController") as! EventContentsViewController
        infoVC.eventId = list[index].eventId
        
        self.navigationController?.push(viewController:infoVC)
    }
    
    @objc
    fileprivate func onClickBackBtn() {
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
        if self.list.count <= 0 {
            return 0
        }
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
        let item = self.list[indexPath.row]
        let imgurl: String = "\(Const.EV_PAY_SERVER)/assets/images/event/events/adapters/\(item.imagePath)"
        if !imgurl.isEmpty {
            cell.eventImageView.contentMode = .scaleAspectFit
            cell.eventImageView.clipsToBounds = true
            cell.eventImageView.sd_setImage(with: URL(string: imgurl), placeholderImage: UIImage(named: "AppIcon"))
            
        } else {
            cell.eventImageView.image = UIImage(named: "AppIcon")
            cell.eventImageView.contentMode = .scaleAspectFit
        }
        
        cell.eventCommentView.text = item.description
        cell.eventEndDateView.text = "행사종료 : \(item.endDate)"
        
        if item.state > EVENT_IN_PROGRESS {
            print("PJS HEREAHAHAHAHA 1")
            cell.isUserInteractionEnabled = false
            cell.eventStatusView.isHidden = false
            if item.state == EVENT_SOLD_OUT{
                cell.eventStatusImageView.image = UIImage(named: "ic_event_soldout")
            }else{
                cell.eventStatusImageView.image = UIImage(named: "ic_event_end")
            }
        }else{
            print("PJS HEREAHAHAHAHA 2")
            cell.isUserInteractionEnabled = true
            cell.eventStatusView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension EventViewController {
    func getEventList() {
        indicatorControll(isStart: true)
        
        Server.getEventList { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                self.list.removeAll()
                
                print("PJS json value = \(json.rawString())")
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
                        
                        self.list.append(item)
                        
                    }
                }
                
                self.updateTableView()
                self.indicatorControll(isStart: false)
            } else {
                self.updateTableView()
                self.indicatorControll(isStart: false)
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 제보하기 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
}
