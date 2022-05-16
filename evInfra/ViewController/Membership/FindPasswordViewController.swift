//
//  FindPasswordViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//


internal final class FindPasswordViewController: BaseViewController {
    
    // MARK: UI
    
    private lazy var callCenterImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "callCenter")
    }
    
    private lazy var guideStrTopLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "기존 비밀번호가 기억나지 않는 경우,\n고객센터 연결이 필요합니다."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = UIColor(named: "content-primary")
        $0.textAlignment = .center
    }
    
    private lazy var guideStrBottomLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "아래 버튼을 눌러 고객센터로 전화주시기 바랍니다."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = UIColor(named: "content-secondary")
        $0.textAlignment = .center
    }
    
    // MARK: VARIABLE
    
    
    //MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareActionBar(with: "비밀번호 찾기")
    }
}
