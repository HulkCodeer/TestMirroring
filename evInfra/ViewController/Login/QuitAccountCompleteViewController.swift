//
//  QuitAccountCompleteViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/29.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import RxSwift

internal final class QuitAccountCompleteViewController: CommonBaseViewController {
    
    // MARK: UI
    
    private lazy var titleLbl = UILabel().then {
        
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.text = "회원탈퇴가 완료되었습니다."
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private lazy var subTitleLbl = UILabel().then {
        
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.text = """
        아쉽지만 회원님과의
        다음 만남을 기대하겠습니다.

        보고싶을 거에요!
        """
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var totalStackView = UIStackView().then {
        
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.spacing = 16
    }
    
    private lazy var completeBtn = RectButton(level: .primary).then {
        
        $0.setTitle("확인", for: .normal)        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = true
        $0.IBcornerRadius = 6
    }
    
    // MARK: VARIABLE
    
    private let disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        totalStackView.addArrangedSubview(titleLbl)
        totalStackView.addArrangedSubview(subTitleLbl)
        
        self.contentView.addSubview(completeBtn)
        completeBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completeBtn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                GlobalDefine.shared.mainNavi?.popToMain()                
            })
            .disposed(by: self.disposebag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
