//
//  BoardDetailViewController.swift
//  evInfra
//
//  Created by PKH on 2022/01/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

class BoardDetailViewController: UIViewController {

    @IBOutlet var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        self.detailTableView.register(UINib(nibName: "BoardDetailTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "BoardDetailTableViewHeader")
        self.detailTableView.register(UINib(nibName: "BoardDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardDetailTableViewCell")
    }
}

extension BoardDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BoardDetailTableViewHeader") as? BoardDetailTableViewHeader else { return UIView() }
            
            return view
        } else {
            // 댓글이 없을 경우, empty view 표시
            
            // 댓글이 있을 경우, 테이블뷰 셀 표시
            guard let view = tableView.dequeueReusableCell(withIdentifier: "BoardDetailTableViewCell") as? BoardDetailTableViewCell else { return UIView() }
            
            return view
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // section은 무조건 댓글갯수 + 1(헤더)
        return 2
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: detailTableView.frame.width, height: 4))
            footerView.backgroundColor = UIColor(named: "nt-0")
            return footerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
}

extension BoardDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 대댓글이 있을 경우 그 갯수 만큼
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoardDetailTableViewCell", for: indexPath) as? BoardDetailTableViewCell else { return UITableViewCell() }
        
        return cell
    }
}
