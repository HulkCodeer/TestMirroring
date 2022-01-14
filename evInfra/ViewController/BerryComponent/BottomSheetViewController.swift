//
//  BottomSheetViewController.swift
//  evInfra
//
//  Created by SH on 2022/01/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import AVFoundation

protocol BottomSheetDelegate {
    func onSelected(index: Int)
}
class BottomSheetViewController: UIViewController {
    
    @IBOutlet var sheetView: UIView!
    @IBOutlet var lbTitle: UILabel!
    @IBOutlet var tableContent: UITableView!
    
    var titleStr: String?
    var contentList: Array<String>?
    var delegate: BottomSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        lbTitle.text = titleStr
        tableContent.dataSource = self
        tableContent.delegate = self
        tableContent.reloadData()
    }
}
extension BottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = contentList {
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomSheetTableViewCell", for: indexPath) as! BottomSheetTableViewCell
        if let list = contentList {
            cell.lbRowText.text = list[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = self.delegate {
            delegate.onSelected(index: indexPath.row)
        }
        dismiss(animated: true, completion: nil)
    }
}
