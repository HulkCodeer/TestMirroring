//
//  NoticeContentViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 20..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

class NoticeContentViewController: UIViewController {

    @IBOutlet weak var content: UITextView!
    var noticeContent = ""
    var pageIndex : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        content.isEditable = false
        content.dataDetectorTypes = .link
        content.sizeToFit()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        content.text = self.noticeContent
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
