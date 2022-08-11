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

internal class DatePickerView: UIStackView {
    private let disposeBag = DisposeBag()
    
    private let toolbar = UIToolbar()
    private let doneButton = UIBarButtonItem().then {
        $0.title = "Done"
        $0.style = .plain
    }
    private let datePicker = UIDatePicker().then {
        if #available(iOS 13.4, *) {
            $0.preferredDatePickerStyle = .wheels
        }
        
        $0.locale = Locale(identifier: "ko_KO")
        $0.datePickerMode = .date
        $0.maximumDate = Date()
    }

    private let formatter = DateFormatter().then {
        let locale = Locale(identifier: "ko_KO")
        
        $0.dateFormat = Constant.date.yearMonthDayHangul
        $0.dateStyle = .long
        $0.timeStyle = .none
        $0.locale = locale
    }

    lazy var dateRelay = doneButton.rx.tap
        .compactMap { [weak self] in
            return self?.datePicker.date
        }
    
    init() {
        super.init(frame: .zero)

        setUI()
        subscribeUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        toolbar.setItems([doneButton], animated: false)
        
        self.axis = .vertical
        self.alignment = .fill
        self.distribution = .fillProportionally
        
        self.addArrangedSubview(toolbar)
        self.addArrangedSubview(datePicker)
    }
    
    private func subscribeUI() {
        doneButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.isHidden = true
            })
            .disposed(by: disposeBag)
    }

    // MARK: Action

    func configure(_ date: Date) {
        let dateStr = date.toString()
        guard let convertDate = formatter.date(from: dateStr) else { return }
        datePicker.date = convertDate  //date //formatter.string(from: date)
    }
    
    func configure(_ dateStr: String) {
        guard let convertDate = formatter.date(from: dateStr) else { return }
        datePicker.date = convertDate
    }
    
}
