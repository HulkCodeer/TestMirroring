//
//  AceeptTermsCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

internal final class AcceptTermsCell: UITableViewCell {
    private lazy var totalView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var checkBtn = CheckBox().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isSelected = false
    }

    private lazy var titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.textColor = Colors.contentPrimary.color
    }

    private lazy var titleBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private lazy var arrowImgView = ChevronArrow.init(.size24(.right)).then {
        $0.translatesAutoresizingMaskIntoConstraints = false                
        $0.IBimageColor = Colors.contentPrimary.color
    }
    
    private lazy var arrowImgViewBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private var disposeBag = DisposeBag()

    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.makeUI()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func makeUI() {
        self.contentView.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        totalView.addSubview(checkBtn)
        checkBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
        }

        totalView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkBtn.snp.trailing).offset(16)
            $0.top.bottom.equalToSuperview()
        }
        
        totalView.addSubview(self.titleBtn)
        titleBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        totalView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(24)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        totalView.addSubview(arrowImgViewBtn)
        arrowImgViewBtn.snp.makeConstraints {
            $0.center.equalTo(arrowImgView.snp.center)
            $0.width.height.equalTo(44)
        }
    }

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }

    internal func bind(to viewModel: AceeptTermsCellViewModel) {
        viewModel.titleData
            .drive(titleLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        viewModel.checkData
            .drive(checkBtn.rx.isSelected)
            .disposed(by: self.disposeBag)
        
        viewModel.termsTypeData
            .drive(onNext: { [weak self] termsType in
                guard let self = self else { return }                
                let isHidden = termsType == .age
                self.arrowImgView.isHidden = isHidden
                self.arrowImgViewBtn.isHidden = isHidden
            })
            .disposed(by: self.disposeBag)

        self.titleBtn.rx.tap
            .map { [weak self] _ -> Bool in
                guard let self = self else { return false }                
                viewModel.tappedCheckedObservable.onNext(!self.checkBtn.isSelected)
                return !self.checkBtn.isSelected
            }
            .bind(to: checkBtn.rx.isSelected)
            .disposed(by: self.disposeBag)
        
        self.arrowImgViewBtn.rx.tap
            .map { _ in viewModel.index }
            .bind(to: viewModel.tappedMoveObservable)
            .disposed(by: self.disposeBag)
    }
}

internal final class AceeptTermsCellViewModel: NSObject {
    internal let index: Int
    internal let termsTypeData: Driver<NewAcceptTermsViewController.TermsType>
    internal var titleData: Driver<String>
    internal var checkData: Driver<Bool>

    internal let tappedMoveObservable = PublishSubject<Int>()
    internal let tappedCheckedObservable = PublishSubject<Bool>()

    init(with termsType: NewAcceptTermsViewController.TermsType, isChecked: Bool, index: Int) {
        self.index = index

        self.titleData = Observable
            .create { observable -> Disposable in
                observable.onNext(termsType.title)
                return Disposables.create {}
            }
            .asDriver(onErrorJustReturn: "")
        
        self.checkData = Observable
            .create{ observable -> Disposable in
                observable.onNext(isChecked)
                return Disposables.create {}
            }
            .asDriver(onErrorJustReturn: false)
        
        self.termsTypeData = Observable
            .create{ observable -> Disposable in
                observable.onNext(termsType)
                return Disposables.create {}
            }
            .asDriver(onErrorJustReturn: .none)
        
        super.init()
    }    
}


