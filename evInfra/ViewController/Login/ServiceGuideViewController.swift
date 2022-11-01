//
//  ServiceGuideViewController.swift
//  evInfra
//
//  Created by Shin Park on 18/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit

class ServiceGuideViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    private lazy var customNaviBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "이용 안내"
    }
    @IBOutlet weak var listTableView: UITableView!
    
    // sub menu - 이용안내
    let SUB_MENU_TERM_SERVICE  = 0
    let SUB_MENU_TERM_PERSONAL = 1
    let SUB_MENU_TERM_LOCATION = 2
    let SUB_MENU_TERM_MEMBERSHIP = 3
    let SUB_MENU_LICENCE       = 4
    let SUB_MENU_CONTACT       = 5
    let SUB_MENU_BUSINESS_INFO = 6
    
    var list = ["서비스 이용약관", "개인정보처리방침", "위치기반서비스 이용약관", "회원카드 이용약관", "라이센스", "제휴문의", "사업자정보"]
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(customNaviBar)
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ServiceGuideCell",
            for: indexPath
        )
        cell.selectionStyle = .none
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsViewControll = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        switch indexPath.row {
        case SUB_MENU_TERM_SERVICE: // 서비스 이용약관
            termsViewControll.tabIndex = .UsingTerms
            
        case SUB_MENU_TERM_PERSONAL: // 개인정보처리방침
            termsViewControll.tabIndex = .PersonalInfoTerms
            
        case SUB_MENU_TERM_LOCATION: // 위치기반서비스 이용약관
            termsViewControll.tabIndex = .LocationTerms
            
        case SUB_MENU_TERM_MEMBERSHIP: // 회원카드 이용약관
            termsViewControll.tabIndex = .MembershipTerms
            
        case SUB_MENU_LICENCE: // 라이센스
            termsViewControll.tabIndex = .Licence
            
        case SUB_MENU_CONTACT: // 제휴문의
            termsViewControll.tabIndex = .Contact
            
        case SUB_MENU_BUSINESS_INFO:
            termsViewControll.tabIndex = .BusinessInfo
            
        default:
            termsViewControll.tabIndex = .UsingTerms
        }
        
        self.navigationController?.push(viewController: termsViewControll)
    }
}
