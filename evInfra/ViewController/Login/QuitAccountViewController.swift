//
//  QuitAccountViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/06/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class QuitAccountViewController: CommonBaseViewController, StoryboardView {
    
    enum ReasonType: CaseIterable {
        case deleteVery
        case delteMembership
        case reSign
        case unRecoverable
        
        var mainTitle: String {
            switch self {
            case .deleteVery:
                return "고객님의 소중한 베리가 모두 사라져요"
            case .delteMembership:
                return "회원카드가 삭제되어요"
            case .reSign:
                return "처음부터 다시 가입해야 해요"
            case .unRecoverable:
                return "복구할 수 없어요"
            }
        }
        
        var subTitle: String {
            switch self {
            case .deleteVery:
                return "고객님께서 모은 000베리가 삭제되어요.\n사라진 베리는 재 가입 시 복구되지 않아요."
            case .delteMembership:
                return "해당 카드로 다시 충전을 할 수 없어요."
            case .reSign:
                return "탈퇴 시 정보가 삭제되어 필요한 정보는 다시 입력 및 등록해야해요."
            case .unRecoverable:
                return "탈퇴 후 삭제된 정보는 재가입/복구 요청을 하여도 삭제되어 복구할 수 없어요."
            }
        }
    }
    
    private lazy var mainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.backgroundAlwaysDark.color
        $0.textAlignment = .natural
        $0.text = "EV Infra를 떠나시는군요.."
        $0.numberOfLines = 1
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.textAlignment = .natural
        $0.text = "떠나기 전 아래 유의사항을 확인해주세요."
        $0.numberOfLines = 1
    }
    
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
    
    private lazy var guideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = Colors.contentSecondary.color
        $0.text = "위 유의사항에 동의하고 탈퇴하시겠어요?"
        $0.textAlignment = .natural
        $0.numberOfLines = 1
    }
                    
    private lazy var quitBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("탈퇴하기", for: .normal)
        $0.setTitle("탈퇴하기", for: .disabled)
        $0.setBackgroundColor(Colors.backgroundDisabled.color, for: .disabled)
        $0.setBackgroundColor(Colors.backgroundPositive.color, for: .normal)
        $0.setTitleColor(Colors.contentPrimary.color, for: .normal)
        $0.setTitleColor(Colors.contentDisabled.color, for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.isEnabled = true
        $0.IBcornerRadius = 6
    }
    
    private lazy var totalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.spacing = 16
    }
    
    // MARK: SYSTEM FUNC
    
    init(reactor: QuitAccountReactor) {
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
        
        self.contentView.addSubview(quitBtn)
        quitBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(guideLbl)
        guideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(quitBtn.snp.top).offset(-16)
            $0.height.equalTo(16)
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(guideLbl.snp.top).offset(-16)
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        totalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        totalView.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.leading.equalTo(mainTitleLbl.snp.leading)
            $0.trailing.equalTo(mainTitleLbl.snp.trailing)
        }
        
        totalView.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.top.equalTo(subTitleLbl.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
                
        for reasonType in ReasonType.allCases {
            totalStackView.addArrangedSubview(self.createReasonView(mainTitle: reasonType.mainTitle, subTitle: reasonType.subTitle))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
                
    }
                    
    internal func bind(reactor: QuitAccountReactor) {
        switch MemberManager.shared.loginType {
        case .apple:
            quitBtn.rx.tap
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .asDriver(onErrorJustReturn: ())
                .drive(onNext: {
                    let popupModel = PopupModel(title: "정말 탈퇴하시겠어요?",
                                                message: "아래 버튼 클릭 시, 즉시 탈퇴가 완료되어 이전으로 돌아갈 수 없어요.",
                                                confirmBtnTitle: "탈퇴하기", cancelBtnTitle: "취소",
                                                confirmBtnAction: { [weak self] in
                        guard let self = self else { return }
                        Observable.just(QuitAccountReactor.Action.deleteAppleAccount)
                            .bind(to: reactor.action)
                            .disposed(by: self.disposeBag)
                    }, textAlignment: .center)
                    
                    let popup = ConfirmPopupViewController(model: popupModel)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                    })
                })
                .disposed(by: self.disposeBag)
                        
        case .kakao:
            quitBtn.rx.tap
                .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
                .map{ QuitAccountReactor.Action.deleteKakaoAccount }
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
            
        default: break
        }
        
        reactor.state.compactMap { $0.isComplete }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { _ in
                LoginHelper.shared.logout(completion: { success in
                    if success {
                        let viewcon = QuitAccountCompleteViewController()
                        GlobalDefine.shared.mainNavi?.pushViewController(viewcon, animated: true)
                    } else {
                        Snackbar().show(message: "다시 시도해 주세요.")
                    }
                })
            })
            .disposed(by: self.disposeBag)
    }
    
    private func createReasonView(mainTitle: String, subTitle: String) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.backgroundSecondary.color
            $0.IBcornerRadius = 8
        }
        
        let mainTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = mainTitle
            $0.textAlignment = .natural
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = Colors.backgroundAlwaysDark.color
        }
        
        view.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        let subTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = subTitle
            $0.textAlignment = .natural
            $0.numberOfLines = 2
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = Colors.contentTertiary.color
        }
        
        view.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.bottom.equalToSuperview().offset(-16)
        }
        
        return view
    }
}
