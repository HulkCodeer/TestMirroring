//
//  DatePickerView.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/10.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

internal class DatePickerView: UIView {
    private lazy var disposeBag = DisposeBag()
    
    private lazy var line = UIView().then {
        $0.backgroundColor = Colors.nt2.color
    }
    private lazy var customToolbar = UIView().then {
        $0.backgroundColor = Colors.backgroundDisabled.color
    }
    private lazy var doneButton = UIButton().then {
        $0.setTitle("Done", for: .normal)
        $0.setTitleColor(Colors.contentPositive.color, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    private lazy var datePicker = UIDatePicker().then {
        if #available(iOS 13.4, *) {
            $0.preferredDatePickerStyle = .wheels
        }
        
        $0.locale = Locale(identifier: "ko_KO")
        $0.datePickerMode = .date
    }

    private lazy var formatter = DateFormatter().then {
        let locale = Locale(identifier: "ko_KO")
        
        $0.dateFormat = Constants.date.yearMonthDayHangul
        $0.dateStyle = .long
        $0.timeStyle = .none
        $0.locale = locale
    }

    lazy var dateObservable = doneButton.rx.tap
        .compactMap { [weak self] in
            return self?.datePicker.date
        }
    
    init() {
        super.init(frame: .zero)

        setUI()
        setConstraints()
        subscribeUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.backgroundColor = Colors.backgroundPrimary.color
        self.frame.size = .init(width: UIScreen.main.bounds.width, height: 140)
        
        self.addSubview(line)
        self.addSubview(customToolbar)
        self.addSubview(datePicker)
        
        customToolbar.addSubview(doneButton)
    }
    
    private func setConstraints() {
        let lineHeight: CGFloat = 0.5
        let toolbarHeight: CGFloat = 40
        let buttonWidth: CGFloat = 50
        
        let buttonPadding: CGFloat = 20
        
        line.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(lineHeight)
        }
        
        customToolbar.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(toolbarHeight)
        }
        doneButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(buttonPadding)
            $0.width.equalTo(buttonWidth)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(customToolbar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func subscribeUI() {
        doneButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { owner, _ in
                owner.configure(owner.datePicker.date)
                owner.isHidden = true
            })
            .disposed(by: disposeBag)
    }

    // MARK: Action

    func configure(_ date: Date, maximumDate: Date? = Date()) {
        let dateStr = date.toString()
        guard let convertDate = formatter.date(from: dateStr) else { return }
        
        datePicker.date = convertDate
        datePicker.maximumDate = maximumDate
    }
    
    func configure(_ dateStr: String, maximumDate: Date? = Date()) {
        guard let convertDate = formatter.date(from: dateStr) else { return }
        
        datePicker.date = convertDate
        datePicker.maximumDate = maximumDate
    }
    
    func minimumDate(date: Date?) {
        guard let date = date else { return }
        datePicker.minimumDate = date
    }
    
}
