//
//  MyPageCarTableViewCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class MyPageCarListCell: CommonBaseTableViewCell, ReactorKit.View {
    internal var disposeBag = DisposeBag()
    
    override func makeUI() {
        super.makeUI()
        // add shadow on cell
    }
        
    internal func bind(reactor: MyPageCarListReactor) {
        
    }
}
