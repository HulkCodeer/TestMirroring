//
//  FindPasswordViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift


internal final class FindPasswordViewController: BaseViewController {
    
    // MARK: UI
    
    private lazy var contentTotalView = UIView().then {
        
    }
    
    private lazy var callCenterImgView = UIImageView().then {
        
        $0.image = UIImage(named: "callCenter")
    }
    
    private lazy var guideTextTopLbl = UILabel().then {
        
        $0.text = "기존 비밀번호가 기억나지 않는 경우,\n고객센터 연결이 필요합니다."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = UIColor(named: "content-primary")
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private lazy var guideTextBottomLbl = UILabel().then {
        
        $0.text = "아래 버튼을 눌러 고객센터로 전화주시기 바랍니다."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(named: "content-secondary")
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private lazy var callCenterTotalView = UIView().then {
        
        $0.backgroundColor = UIColor(named: "background-positive")
        $0.IBcornerRadius = 6
    }
    
    private lazy var callCenterIconImgView = UIImageView().then {
        
        $0.image = UIImage(named: "icon_call_md")
        $0.tintColor = UIColor(named: "content-primary")
    }
    
    private lazy var callCenterTextLbl = UILabel().then {
        
        $0.text = "고객센터 전화하기"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = UIColor(named: "content-primary")
        $0.sizeToFit()
    }
    
    private lazy var callCenterBtn = UIButton()
    
    // MARK: VARIABLE
    
    private var disposebag = DisposeBag()
    
    
    //MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(contentTotalView)
        contentTotalView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-56)
            $0.height.greaterThanOrEqualTo(348)
        }
        
        contentTotalView.addSubview(callCenterImgView)
        callCenterImgView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(216)
        }
        
        contentTotalView.addSubview(guideTextTopLbl)
        guideTextTopLbl.snp.makeConstraints {
            $0.top.equalTo(callCenterImgView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        contentTotalView.addSubview(guideTextBottomLbl)
        guideTextBottomLbl.snp.makeConstraints {
            $0.top.equalTo(guideTextTopLbl.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        
        contentTotalView.addSubview(callCenterTotalView)
        callCenterTotalView.snp.makeConstraints {
            $0.top.equalTo(guideTextBottomLbl.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(178)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        contentTotalView.addSubview(callCenterBtn)
        callCenterBtn.snp.makeConstraints {
            $0.center.equalTo(callCenterTotalView.snp.center)
            $0.width.equalTo(callCenterTotalView.snp.width)
            $0.height.equalTo(callCenterTotalView.snp.height)
        }

        callCenterTotalView.addSubview(callCenterIconImgView)
        callCenterIconImgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(20)
            $0.centerY.equalToSuperview()
        }

        callCenterTotalView.addSubview(callCenterTextLbl)
        callCenterTextLbl.snp.makeConstraints {
            $0.leading.equalTo(callCenterIconImgView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callCenterBtn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                guard let number = URL(string: "tel://070-8633-9009") else { return }
                UIApplication.shared.open(number)
            })
            .disposed(by: self.disposebag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareActionBar(with: "비밀번호 찾기")
    }
}
