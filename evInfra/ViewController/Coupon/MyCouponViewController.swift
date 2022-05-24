//
//  MyCouponViewController.swift
//  evInfra
//
//  Created by 이신광 on 06/11/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class MyCouponViewController: UIViewController {

    private let STATUS_NORMAL = 0
    private let STATUS_END_DATE = 1
    private let STATUS_USED = 2
    private let STATUS_EVENT_CANCEL = 3
    private let STATUS_CANCELED = 4
    
    @IBOutlet weak var emptyView: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var list = Array<Coupon>()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareTableView()
        
        getEventList()
    }
}

extension MyCouponViewController {
    
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        let couponCodeBtn = UIButton()
        couponCodeBtn.setTitle("쿠폰 번호 등록", for: .normal)
        couponCodeBtn.setTitleColor(UIColor(named: "content-primary")!, for: .normal)
        couponCodeBtn.titleLabel?.font = .systemFont(ofSize: 14)
        couponCodeBtn.addTarget(self, action: #selector(handlecouponCodeBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.rightViews = [couponCodeBtn]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "보유쿠폰"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
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
        } else {
            self.emptyView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    func  goToEventInfo(index: Int) {
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCouponContentsViewController") as! MyCouponContentsViewController
        infoVC.couponId = list[index].couponId
        infoVC.couponTitle = list[index].title
        self.navigationController?.push(viewController:infoVC)
    }
    
    @objc
    fileprivate func onClickBackBtn() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func handlecouponCodeBtn() {
        self.indicator.startAnimating()
        
        let mypageVC = storyboard?.instantiateViewController(withIdentifier: "CouponCodeViewController") as! CouponCodeViewController
        navigationController?.push(viewController: mypageVC)
    }
}

extension MyCouponViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToEventInfo(index:indexPath.row)
    }
}

extension MyCouponViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCouponTableViewCell", for: indexPath) as! MyCouponTableViewCell
        let item = self.list[indexPath.row]
        let imgurl: String = "\(Const.EV_PAY_SERVER)/assets/images/event/coupons/adapters/\(item.imagePath)"
        if !imgurl.isEmpty {
            cell.couponImageView.sd_setImage(with: URL(string: imgurl), placeholderImage: UIImage(named: "AppIcon"))
        } else {
            cell.couponImageView.image = UIImage(named: "AppIcon")
            cell.couponImageView.contentMode = .scaleAspectFit
        }
        
        cell.couponCommentLabel.text = item.description
        cell.couponEndDateLabel.text = "쿠폰만료 : \(item.endDate)"
        
        switch item.state {
            case STATUS_NORMAL:
                cell.isUserInteractionEnabled = true
                cell.couponStatusView.isHidden = true
                cell.couponStatusImageView.isHidden = true
                
            // 쿠폰 기간 지남
            case STATUS_END_DATE:
                cell.isUserInteractionEnabled = false
                cell.couponStatusView.isHidden = false
                cell.couponStatusImageView.isHidden = false
                cell.couponStatusImageView.image = UIImage(named: "ic_event_outdate")

            // 쿠폰 사용
            case STATUS_USED:
                cell.isUserInteractionEnabled = false
                cell.couponStatusView.isHidden = false
                cell.couponStatusImageView.isHidden = false
                cell.couponStatusImageView.image = UIImage(named: "ic_event_used")

            // 이벤트 취소
            case STATUS_EVENT_CANCEL:
                cell.isUserInteractionEnabled = false
                cell.couponStatusView.isHidden = false
                cell.couponStatusImageView.isHidden = false
                cell.couponStatusImageView.image = UIImage(named: "ic_event_end")

            // 취소된 쿠폰
            case STATUS_CANCELED:
                cell.isUserInteractionEnabled = false
                cell.couponStatusView.isHidden = false
                cell.couponStatusImageView.isHidden = false
                cell.couponStatusImageView.image = UIImage(named: "ic_event_canceled")
            
            default:
                cell.isUserInteractionEnabled = true
                cell.couponStatusView.isHidden = true
                cell.couponStatusImageView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension MyCouponViewController {
    func getEventList() {
        indicatorControll(isStart: true)
        
        Server.getCouponList { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                self.list.removeAll()
                if json["code"].intValue != 1000 {
                    self.updateTableView()
                    self.indicatorControll(isStart: false)
                } else {
                    for jsonRow in json["lists"].arrayValue {
                        let item: Coupon = Coupon.init()
                        
                        item.couponId = jsonRow["id"].intValue
                        item.state = jsonRow["state"].intValue
                        item.endDate  = jsonRow["finish_date"].stringValue
                        item.description = jsonRow["description"].stringValue
                        item.imagePath = jsonRow["image"].stringValue
                        item.title = jsonRow["title"].stringValue
                        
                        if (item.state == 0) {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            if let finishDate = formatter.date(from: item.endDate) {
                                let currentDate = Date()
                                if finishDate <= currentDate {
                                    item.state = self.STATUS_END_DATE
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
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 내 쿠폰함 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
}
