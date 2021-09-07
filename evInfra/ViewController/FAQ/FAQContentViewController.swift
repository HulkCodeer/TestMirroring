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
    
    var faqTitle:String!
    var contentArr:[FAQContent] = [FAQContent]()
    
    override func viewDidLoad() {
        initView()
    }
    
    func initView() {
        faqContentTitle.text = faqTitle
        
    }
}
