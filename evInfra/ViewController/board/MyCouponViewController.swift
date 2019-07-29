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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabelView: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var list = Array<EventCoupon>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        
        prepareTableView()
        
        getCouponList()
    }
}

extension MyCouponViewController {
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "내 쿠폰함"
        self.navigationController?.isNavigationBarHidden = false
    }

    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        tableView.tableFooterView = UIView()
        
        emptyLabelView.isHidden = true
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
            self.emptyLabelView.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        } else {
            self.emptyLabelView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    func  goToCouponInfo(index: Int) {
        guard let couponId = self.list[index].coponId else {
            return
        }
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCouponInfoViewController") as! MyCouponInfoViewController
        infoVC.couponId = couponId
        
        self.navigationController?.push(viewController:infoVC)
    }
    
    @objc
    fileprivate func onClickBackBtn() {
        self.navigationController?.pop()
    }
}

extension MyCouponViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToCouponInfo(index:indexPath.row)
    }
}

extension MyCouponViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.list.count <= 0 {
            return 0
        }
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCouponTableViewCell", for: indexPath) as! MyCouponTableViewCell
        let item = self.list[indexPath.row]
        let imgurl: String = item.getImageUrl()
        if !imgurl.isEmpty {
            cell.CouponImgView.contentMode = .scaleAspectFit
            cell.CouponImgView.clipsToBounds = true
            cell.CouponImgView.sd_setImage(with: URL(string: imgurl), placeholderImage: UIImage(named: "AppIcon"))
            
        } else {
            cell.CouponImgView.image = UIImage(named: "AppIcon")
            cell.CouponImgView.contentMode = .scaleAspectFit
        }

        cell.CouponDescriptionView.text = item.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var eDate = ""
        if let endDate = item.endDate {
            eDate = dateFormatter.string(from: endDate)
        }
        cell.CouponUsedDateView.text = "쿠폰만료 : " + eDate
        
        if item.checkCouponStatus(imageView: cell.CouponStatusImgView) {
            cell.isUserInteractionEnabled = true
            cell.CouponStatusView.isHidden = true
        } else {
            cell.isUserInteractionEnabled = false
            cell.CouponStatusView.isHidden = false
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
    func getCouponList() {
        indicatorControll(isStart: true)

        Server.getCouponList { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                self.list.removeAll()
                
                if json["result_code"].exists() {
                    
                } else {
                    for jsonRow in json.arrayValue {
                        let item: EventCoupon = EventCoupon.init()
                        
                        item.coponId = jsonRow["id"].intValue
                        item.c_state = jsonRow["c_state"].intValue
                        item.e_state = jsonRow["e_state"].intValue
                        item.imagePath = jsonRow["img"].stringValue
                        item.description = jsonRow["msg"].stringValue
                        
                        let eDate: String? = jsonRow["end_date"].stringValue
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.locale = Locale(identifier: "ko_kr")
                        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
                        if let endDate = eDate, !endDate.isEmpty {
                            item.endDate = dateFormatter.date(from: endDate)
                        } else {
                            item.endDate = Date()
                        }
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
