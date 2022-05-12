//
//  MembershipReJoinViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal final class MembershipReissuanceViewController: UIViewController {
    
    // MARK: UI
    
    private lazy var guideLblTop = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "재발급 신청 전, 본인 확인을 위해"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .left
        $0.textColor = UIColor(named: "content-primary")
    }
    
    private lazy var guideLblBottom = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "결제 비밀번호를 입력해주세요."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .left
        $0.textColor = UIColor(named: "content-primary")
    }
    
    private lazy var passwordTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "비밀번호"
    }
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        prepareActionBar(with: "재발급 신청")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
