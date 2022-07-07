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

    private lazy var arrowImageView = ChevronArrow().then {
        $0.translatesAutoresizingMaskIntoConstraints = false        
        $0.tintColor = Colors.contentPrimary.color
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
        
        self.totalView.addSubview(checkBtn)
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

        totalView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(24)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        totalView.addSubview(self.titleBtn)
        titleBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }

    internal func bind(to viewModel: AceeptTermsCellViewModel) {
        viewModel.dataDriver
            .drive(self.titleLabel.rx.text)
            .disposed(by: self.disposeBag)

        self.titleBtn.rx.tap
            .map { _ in viewModel.index }
            .bind(to: viewModel.tappedObservable)
            .disposed(by: self.disposeBag)
    }
}

internal final class AceeptTermsCellViewModel: NSObject {
    internal let index: Int
    internal let dataDriver: Driver<String>

    internal let tappedObservable = PublishSubject<Int>()

    init(with title: String, index: Int) {
        self.index = index

        self.dataDriver = Observable
            .create { observable -> Disposable in
                observable.onNext(title)
                return Disposables.create {}
            }
            .asDriver(onErrorJustReturn: "")
        super.init()
    }
}


