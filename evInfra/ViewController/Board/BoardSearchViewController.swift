//
//  BoardSearchViewController.swift
//  evInfra
//
//  Created by PKH on 2022/02/16.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit

class BoardSearchViewController: UIViewController {

    var searchBarView = SearchBarView()
    var searchTypeSelectView = SearchTypeSelectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // searchbar UI
        view.addSubview(searchBarView)
        view.addSubview(searchTypeSelectView)
        
        searchBarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        searchTypeSelectView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
    }
}
