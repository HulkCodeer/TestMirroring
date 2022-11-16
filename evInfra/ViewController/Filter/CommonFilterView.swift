//
//  CommonFilterView.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/17.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

internal class CommonFilterView: UIView {
    typealias FilterView = (totalView: UIView, imgView: UIImageView, btn: UIButton)
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.makeUI()
    }
    
    func makeUI() {}
    
    func createCommonFilterTypeView(_ filterType: any Filter, reactor: FilterReactor) -> FilterView {        
        let imgView = UIImageView().then {
            $0.image = filterType.typeImageProperty.image
            $0.tintColor = filterType.displayImageColor
        }
        
        let titleLbl = UILabel().then {
            $0.text = "\(filterType.typeTilte)"
            $0.font = .systemFont(ofSize: 14)
        }
        
        let btn = UIButton().then {
            $0.isSelected = filterType.isSelected
        }
        
        let view = UIView().then {
            $0.addSubview(imgView)
            imgView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(48)
            }
            
            $0.addSubview(titleLbl)
            titleLbl.snp.makeConstraints {
                $0.top.equalTo(imgView.snp.bottom).offset(4)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(16)
            }

            $0.addSubview(btn)
            btn.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
                        
        return (view, imgView, btn)
    }
}
