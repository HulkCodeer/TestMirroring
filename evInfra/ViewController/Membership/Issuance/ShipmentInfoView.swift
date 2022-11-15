//
//  ShipmentInfoView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/25.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

internal final class ShipmentInfoView: UIView {
    
    // MARK: UI
    
    private lazy var totalView = UIView()
    
    private lazy var guideLbl = UILabel().then {
        $0.text = "발송지 정보"
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .black
        $0.textAlignment = .natural
    }
    
    private lazy var addressTotalView = UIView()
    
    private lazy var addressGuideLbl = UILabel().then {
        $0.text = "주소"
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    
    private lazy var addressContentsLbl = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.text = ""
    }
    
    private lazy var receiveTotalView = UIView()
    
    private lazy var receiveNameGuideLbl = UILabel().then {
        $0.text = "받는이"
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    
    private lazy var receiveNameLbl = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.text = ""
    }
    
    private lazy var phoneTotalView = UIView()
    
    private lazy var phoneGuideLbl = UILabel().then {
        $0.text = "연락처"
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    
    private lazy var phoneLbl = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.text = ""
    }
    
    // MARK: VARIABLE
    
    private var disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
            
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    // MARK: FUNC
    
    private func makeUI() {
        self.addSubview(totalView)
        totalView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-24)
        }
        
        totalView.addSubview(guideLbl)
        guideLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(26)
        }
        
        totalView.addSubview(addressTotalView)
        addressTotalView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(guideLbl.snp.bottom).offset(10)
        }
        
        addressTotalView.addSubview(addressGuideLbl)
        addressGuideLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        addressTotalView.addSubview(addressContentsLbl)
        addressContentsLbl.snp.makeConstraints {
            $0.top.equalTo(addressGuideLbl.snp.top)
            $0.leading.equalToSuperview().offset(56)
            $0.height.greaterThanOrEqualTo(50)
            $0.trailing.bottom.equalToSuperview()
        }
                
        totalView.addSubview(receiveTotalView)
        receiveTotalView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(addressTotalView.snp.bottom).offset(8)
        }
        
        receiveTotalView.addSubview(receiveNameGuideLbl)
        receiveNameGuideLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        receiveTotalView.addSubview(receiveNameLbl)
        receiveNameLbl.snp.makeConstraints {
            $0.top.equalTo(receiveNameGuideLbl.snp.top)
            $0.leading.equalToSuperview().offset(56)
            $0.height.equalTo(24)
            $0.trailing.bottom.equalToSuperview()
        }
        
        totalView.addSubview(phoneTotalView)
        phoneTotalView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(receiveTotalView.snp.bottom).offset(8)
            $0.bottom.equalToSuperview()
        }
        
        phoneTotalView.addSubview(phoneGuideLbl)
        phoneGuideLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        phoneTotalView.addSubview(phoneLbl)
        phoneLbl.snp.makeConstraints {
            $0.top.equalTo(phoneGuideLbl.snp.top)
            $0.leading.equalToSuperview().offset(56)
            $0.height.equalTo(24)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-58)
        }
    }
    
    internal func bind(model: MembershipCardInfo.Destination) {
        addressContentsLbl.text = "\(model.addr)\n\(model.addrDtl)"
        receiveNameLbl.text = model.name
        phoneLbl.text = model.phone
    }
}
