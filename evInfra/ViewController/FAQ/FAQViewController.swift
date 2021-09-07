//
//  FAQViewController.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/09/06.
//  Copyright © 2021 soft-berry. All rights reserved.
//
import UIKit
import Material
import Foundation

class FAQViewController: UIViewController{
    
    @IBOutlet var faqTopTableView: UITableView!
    @IBOutlet var tableviewHeight: NSLayoutConstraint!
    
    var faqTopArr:[FAQTop] = [FAQTop]()
    
    override func viewDidLoad() {
        prepareActionBar()
        prepareTableView()
        initView()
    }
    
    func prepareActionBar() {
       let backButton = IconButton(image: Icon.cm.arrowBack)
       backButton.tintColor = UIColor(rgb: 0x15435C)
       backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
              
       navigationItem.leftViews = [backButton]
       navigationItem.hidesBackButton = true
       navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
       navigationItem.titleLabel.text = "자주 묻는 질문"
       self.navigationController?.isNavigationBarHidden = false
   }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    func initView() {
        let faqTopList = FAQTopList()
        self.faqTopArr = faqTopList.getFAQTopArr()
    }
    
    func adjustTableview() {
        if self.faqTopTableView.contentSize.height > 0.0 {
            self.tableviewHeight.constant = self.faqTopTableView.contentSize.height
            faqTopTableView.layoutIfNeeded()
        }
    }
}

extension FAQViewController : UITableViewDelegate, UITableViewDataSource {
    func prepareTableView() {
        faqTopTableView.delegate = self
        faqTopTableView.dataSource = self
        faqTopTableView.autoresizingMask = UIViewAutoresizing.flexibleHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.faqTopArr.count <= 0 {
            return 0
        }
        return faqTopArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("FAQTableViewCell", owner: self, options: nil)?.first as! FAQTableViewCell
        
        cell.faqNumLb.text = String(faqTopArr[indexPath.row].getFAQPriority() + 1)
        cell.faqTitleLb.text = faqTopArr[indexPath.row].getFAQTitle()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.faqTopTableView.deselectRow(at: indexPath, animated: true)
        let faqStoryboard = UIStoryboard(name : "FAQ", bundle: nil)
        let faqContentVC = faqStoryboard.instantiateViewController(withIdentifier: "FAQContentViewController") as! FAQContentViewController
        faqContentVC.faqTitle = faqTopArr[indexPath.row].getFAQTitle()
        faqContentVC.contentArr = faqTopArr[indexPath.row].getFAQContentArr()
        print("csj_", "FAQContentArr.count : ", faqTopArr[indexPath.row].getFAQContentArr().count)
        self.navigationController?.push(viewController: faqContentVC)
//        self.performSegue(withIdentifier: "FAQContentController", sender: nil)
    }
}
