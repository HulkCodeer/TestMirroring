//
//  MyPageCarAddCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/27.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class MyPageCarAddCell: CommonBaseTableViewCell, ReactorKit.View {
    private lazy var addTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var addBorderImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.carEmptyBorder.image
        $0.tintColor = Colors.contentTertiary.color
    }
            
    private lazy var addGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.textColor = Colors.contentTertiary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.text = "차량추가하기"
    }
    
    private lazy var moveAddCarBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    internal var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    override func makeUI() {
        super.makeUI()
        // add shadow on cell
        self.contentView.addSubview(addTotalView)
        addTotalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
        
        addTotalView.addSubview(addBorderImgView)
        addBorderImgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
                                
        addTotalView.addSubview(addGuideLbl)
        addGuideLbl.snp.makeConstraints {
            $0.leading.trailing.centerX.centerY.equalToSuperview()            
            $0.height.equalTo(20)
        }
        
        addTotalView.addSubview(moveAddCarBtn)
        moveAddCarBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
        
    internal func bind(reactor: MyPageCarListReactor) {
        moveAddCarBtn.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { MyPageCarListReactor.Action.moveCarRegisterView }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
}
