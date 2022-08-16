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
import PanModal
import UIKit

internal final class QuitAccountReasonQuestionViewController: CommonBaseViewController, StoryboardView {
    
    enum Const: String {
        case textViewPlaceHolder = "더 자세한 의견을 말씀해주세요."
    }
    
    // MARK: UI
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "회원탈퇴"
    }
    
    private lazy var totalScrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = true
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
        $0.numberOfLines = 1
    }
    
    private lazy var selectBoxArrow = ChevronArrow.init(.size24(.down)).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBimageColor = Colors.contentPrimary.color
    }
    
    private lazy var selectBoxTotalBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var reasonTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    private lazy var reasonMainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "더 자세하게 말씀해주세요."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
    }
    
    private lazy var reasonBorderView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 6
        $0.IBborderColor = Colors.borderOpaque.color
    }
    
    private lazy var reasonNegativeTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }

    private lazy var reasonNegativeIconImgView = Info(.size16).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBimageWidth = 16
        $0.IBimageColor = Colors.contentNegative.color
    }
    
    private lazy var reasonNegativeLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentNegative.color
        $0.text = "1200자 이상 작성할 수 없습니다."
        $0.numberOfLines = 1
    }
            
    private lazy var reasonTextView = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.nt9.color
        $0.delegate = self
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        $0.isScrollEnabled = false
    }
    
    private lazy var reasonTextCountLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = Colors.contentTertiary.color
        $0.text = "0  / 1200"
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다음", for: .normal)
        $0.setTitle("다음", for: .disabled)                
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
        let screenWidth = UIScreen.main.bounds.width
                
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.width.equalTo(screenWidth - 32)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-16)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(totalScrollView)
        totalScrollView.snp.makeConstraints {
            $0.top.equalTo(naviTotalView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextBtn.snp.top).offset(-16)
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        totalScrollView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
                                                    
        totalView.addSubview(dismissKeyboardBtn)
        dismissKeyboardBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        totalView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
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
            $0.bottom.equalToSuperview()
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
            $0.leading.trailing.equalToSuperview()
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
            $0.height.greaterThanOrEqualTo(104)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reasonTextCountLbl.snp.top).offset(-4)
        }

        reasonTotalView.addSubview(reasonNegativeTotalView)
        reasonNegativeTotalView.snp.makeConstraints {
            $0.top.equalTo(reasonBorderView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        reasonNegativeTotalView.addSubview(reasonNegativeIconImgView)
        reasonNegativeIconImgView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(16)
        }

        reasonNegativeTotalView.addSubview(reasonNegativeLbl)
        reasonNegativeLbl.snp.makeConstraints {
            $0.leading.equalTo(reasonNegativeIconImgView.snp.trailing).offset(3)
            $0.top.bottom.trailing.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "회원탈퇴 사유 선택화면"
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            view.layoutIfNeeded()
//            totalScrollView.snp.updateConstraints {
//                $0.bottom.equalTo(nextBtn.snp.top).offset(-keyboardHeight + 60 + self.view.safeAreaInsets.bottom)
//            }
            
            let bottom = keyboardHeight - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) 
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottom, right: 0.0)
            self.totalScrollView.contentInset = contentInsets
            self.totalScrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc private func keyboardDidHide(_ sender: NSNotification) {
        view.layoutIfNeeded()
        let contentsInset: UIEdgeInsets = .zero
        totalScrollView.contentInset = contentsInset
        totalScrollView.scrollIndicatorInsets = contentsInset
                
//        totalScrollView.snp.updateConstraints {
//            $0.bottom.equalTo(nextBtn.snp.top).offset(-16)
//        }
    }
                    
    internal func bind(reactor: QuitAccountReasonQuestionReactor) {
        Observable.just(QuitAccountReasonQuestionReactor.Action.getQuitAccountReasonList)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        selectBoxTotalBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
                
                let rowVC = NewBottomSheetViewController()
                rowVC.items = reactor.currentState.quitAccountReasonList?.compactMap { $0.reasonMessage } ?? []
                rowVC.headerTitleStr = "탈퇴 사유 선택"
                rowVC.view.frame = GlobalDefine.shared.mainNavi?.view.bounds ?? UIScreen.main.bounds
                self.addChildViewController(rowVC)
                self.view.addSubview(rowVC.view)
                                                                              
                rowVC.selectedCompletion = { [weak self] index in
                    guard let self = self else { return }
                    reactor.selectedReasonIndex = index
                    self.selectBoxTitleLbl.text = rowVC.items[index]
                    self.nextBtn.isEnabled = true
                    self.reasonTotalView.isHidden = false
                    
                    rowVC.removeBottomSheet()
                }
            })
            .disposed(by: self.disposeBag)
        
        nextBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let quitReactor = QuitAccountReactor(provider: RestApi())
                quitReactor.reasonID = reactor.currentState.quitAccountReasonList?[reactor.selectedReasonIndex].reasonId ?? ""
                quitReactor.reasonText = self.reasonTextView.text ?? ""
                let viewcon = QuitAccountViewController(reactor: quitReactor)
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            }).disposed(by: self.disposeBag)
    }
}

extension QuitAccountReasonQuestionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        reasonBorderView.IBborderColor = Colors.nt9.color
        textView.textColor = Colors.nt9.color
        
        guard Const.textViewPlaceHolder.rawValue.equals(reasonTextView.text) else {
            return
        }
        textView.text = nil
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        reasonBorderView.IBborderColor = Colors.nt2.color
        textView.textColor = Colors.nt5.color
        
        guard reasonTextView.text.isEmpty else { return }
        textView.text = Const.textViewPlaceHolder.rawValue
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textViewStrCount = textView.text.count
        let isTextCountLimit = textViewStrCount > 1200
        reasonBorderView.IBborderColor =  isTextCountLimit ? Colors.borderNegative.color : Colors.nt9.color
        reasonNegativeTotalView.isHidden = !isTextCountLimit
        textView.text = isTextCountLimit ? String(textView.text.prefix(1200)) : textView.text
        
        reasonTextCountLbl.text = "\(textView.text.count) / 1200"
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if estimatedSize.height <= 104 {
            
            } else if estimatedSize.height <= 216{
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            } else {
                constraint.constant = 216
                textView.isScrollEnabled = true
            }
        }
    }
}
