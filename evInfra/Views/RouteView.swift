//
//  RouteView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/05/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

class RouteView: UIView {
    
    @IBOutlet var swapLocationButton1: UIButton!
    @IBOutlet var swapLocationButton2: UIButton!
    
    @IBOutlet var findStartLocationButton: UIButton!
    @IBOutlet var findViaLocationButton: UIButton!
    @IBOutlet var findDestinationLocationButton: UIButton!
    
    @IBOutlet var clearRouteViewButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        attribute()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        attribute()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed("RouteView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
    }
    
    private func attribute() {
        [findStartLocationButton,
         findViaLocationButton,
         findDestinationLocationButton].forEach {
            $0?.fontSize = 16
            $0?.setTitleColor(UIColor(named: "content-tertiary"), for: .normal)
            $0?.layer.cornerRadius = 5
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
        }
        
        [swapLocationButton1, swapLocationButton2, clearRouteViewButton].forEach {
            $0?.tintColor = UIColor(named: "content-tertiary")
        }
    }
    
}
