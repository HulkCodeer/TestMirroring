//
//  FAQContentViewController.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/09/06.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
import Material
import Foundation

class FAQContentViewController: UIViewController {
    @IBOutlet var faqContentTitle: UILabel!
    @IBOutlet var faqContentTableView: UITableView!
    @IBOutlet var faqContentCallView: UIView!
    @IBOutlet var faqContentTableViewHeight: NSLayoutConstraint!
    
    var faqTitle:String!
    var contentArr:[FAQContent] = [FAQContent]()
    
    override func viewDidLoad() {
        print("csj_", "contenetArr.count : ", contentArr.count)
        prepareTableView()
        initView()
    }
    
    func initView() {
        faqContentTitle.text = faqTitle
        adjustTableview()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onClickCall(_:)))
        self.faqContentCallView.addGestureRecognizer(gesture)
    }
    
    func adjustTableview() {
        if self.faqContentTableView.contentSize.height > 0.0 {
            self.faqContentTableViewHeight.constant = self.faqContentTableView.contentSize.height
            faqContentTableView.layoutIfNeeded()
        }
    }
    
    @objc func onClickCall(_ sender:UITapGestureRecognizer){
        guard let number = URL(string : "tel://" + "070-8633-9009") else {
            return
        }
        UIApplication.shared.open(number)
    }
}
extension FAQContentViewController : UITableViewDelegate, UITableViewDataSource {
    func prepareTableView() {
        faqContentTableView.delegate = self
        faqContentTableView.dataSource = self
        faqContentTableView.autoresizingMask = UIViewAutoresizing.flexibleHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.contentArr.count <= 0 {
            return 0
        }
        return contentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("FAQContentTableViewCell", owner: self, options: nil)?.first as! FAQContentTableViewCell
        
        cell.faqContentLb.isHidden = true
        cell.faqContentIv.isHidden = true
        let comment = contentArr[indexPath.row].getComment()!
        if !comment.isEmpty {
            cell.faqContentLb.isHidden = false
            cell.faqContentLb.text = comment
        }
        let img = contentArr[indexPath.row].getImgName()!
        if !img.isEmpty {
            cell.faqContentIv.isHidden = false
            cell.faqContentIv.image = UIImage(named: img)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
