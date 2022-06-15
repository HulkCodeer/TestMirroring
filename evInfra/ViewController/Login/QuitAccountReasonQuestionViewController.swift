//
//  DeleteAccountViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

internal final class QuitAccountViewController: CommonBaseViewController, StoryboardView {
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "회원탈퇴"
    }
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var dismissKeyboardBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var mainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.backgroundAlwaysDark.color
        $0.textAlignment = .natural
        $0.text = "탈퇴 사유를 선택해주세요."
        $0.numberOfLines = 1
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.textAlignment = .natural
        $0.text = "고객님의 의견을 바탕으로 더 나은 EV Infra가 되겠습니다."
        $0.numberOfLines = 1
    }
    
    private lazy var selectBoxTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBborderColor = Colors.borderOpaque.color
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
    }
    
    private lazy var selectBoxTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.text = "탈퇴사유 선택"
    }
    
    private lazy var selectBoxArrow = ChevronArrow.init(.size24(.down)).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = Colors.contentPrimary.color
    }
    
    private lazy var selectBoxTotalBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var reasonTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var reasonMainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "더 자세하게 말씀해주세요."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
    }
    
    private lazy var reasonTextViewPlaceHolder = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "더 자세한 의견을 말씀해주세요."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
    }
    
    private lazy var reasonBorderView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.IBborderColor = Colors.borderOpaque.color
    }
            
    private lazy var reasonTextView = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.nt9.color
        $0.delegate = self
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
    }
    
    private lazy var reasonTextCountLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.text = "0  / 1200"
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private lazy var nextBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음", for: .normal)
        $0.setTitle("다음", for: .disabled)
        $0.setBackgroundColor(Colors.backgroundDisabled.color, for: .disabled)
        $0.setBackgroundColor(Colors.backgroundPositive.color, for: .normal)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.setTitleColor(Colors.contentDisabled.color, for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = false
        $0.IBcornerRadius = 6
    }
    
    // MARK: SYSTEM FUNC
    
    init(reactor: QuitAccountReasonQuestionReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
                
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top)
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        totalView.addSubview(dismissKeyboardBtn)
        dismissKeyboardBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
                
        totalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(17)
            $0.trailing.equalToSuperview()
        }
        
        totalView.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(17)
            $0.trailing.equalToSuperview()
        }
        
        totalView.addSubview(selectBoxTotalView)
        selectBoxTotalView.snp.makeConstraints {
            $0.top.equalTo(subTitleLbl.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
        
        selectBoxTotalView.addSubview(selectBoxTitleLbl)
        selectBoxTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        selectBoxTotalView.addSubview(selectBoxArrow)
        selectBoxArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        selectBoxTotalView.addSubview(selectBoxTotalBtn)
        selectBoxTotalBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        totalView.addSubview(reasonTotalView)
        reasonTotalView.snp.makeConstraints {
            $0.top.equalTo(selectBoxTotalView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        reasonTotalView.addSubview(reasonMainTitleLbl)
        reasonMainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(1)
            $0.height.equalTo(20)
        }
        
        reasonTotalView.addSubview(reasonBorderView)
        reasonBorderView.snp.makeConstraints {
            $0.top.equalTo(reasonMainTitleLbl.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(156)
        }
        
        reasonBorderView.addSubview(reasonTextCountLbl)
        reasonTextCountLbl.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
                
        reasonBorderView.addSubview(reasonTextView)
        reasonTextView.snp.makeConstraints {
            $0.top.equalTo(reasonMainTitleLbl.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reasonTextCountLbl.snp.top).offset(-4)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectBoxTotalBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let rowVC = GroupViewController()
                rowVC.members = ["충전 및 결제가 불편해요.", "커뮤니티가 짜증나요.", "지도와 충전소 정보가 부정확해요.", "각종 내역을 보기 힘들어요.", "기타"]
                self.presentPanModal(rowVC)
                
                rowVC.selectedCompletion = { [weak self] index in
                    guard let self = self else { return }
                    self.selectBoxTitleLbl.text = rowVC.members[index]
                    self.nextBtn.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: self.disposeBag)
        
        dismissKeyboardBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
    }
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
                
    }
                    
    internal func bind(reactor: QuitAccountReasonQuestionReactor) {
        
    }
}

extension QuitAccountViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        reasonBorderView.IBborderColor = Colors.nt9.color
        reasonTextView.textColor = Colors.nt9.color
        
        guard "더 자세한 의견을 말씀해주세요.".equals(reasonTextView.text) else {
            return
        }
        reasonTextView.text = nil
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        reasonBorderView.IBborderColor = Colors.nt2.color
        reasonTextView.textColor = Colors.nt5.color
        if reasonTextView.text.isEmpty {
            reasonTextView.text = "더 자세한 의견을 말씀해주세요."
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        reasonTextCountLbl.text = "\(reasonTextView.text.count) / 1200"
    }
}
