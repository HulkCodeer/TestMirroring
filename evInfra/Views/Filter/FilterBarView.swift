//
//  FilterBarView.swift
//  evInfra
//
//  Created by SH on 2021/08/11.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

protocol DelegateFilterBarView {
    func showFilterContainer(type: FilterType)
    func startFilterSetting()
}

enum FilterType {
    case price
    case speed
    case place
    case road
    case type
    case none
}

class FilterBarView: UIView {
    
    @IBOutlet weak var btnFilter: UIView!
    
    @IBOutlet weak var btnPrice: UIButton!
    @IBOutlet weak var btnSpeed: UIButton!
    @IBOutlet weak var btnPlace: UIButton!
    @IBOutlet weak var btnRoad: UIButton!
    @IBOutlet weak var btnType: UIButton!
    
    var delegate: DelegateFilterBarView?
    var selected: FilterType = FilterType.none
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnPrice.layer.cornerRadius = 12
        self.btnSpeed.layer.cornerRadius = 12
        self.btnPlace.layer.cornerRadius = 12
        self.btnRoad.layer.cornerRadius = 12
        self.btnType.layer.cornerRadius = 12
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        let view = Bundle.main.loadNibNamed("FilterBarView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        btnFilter.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickOpen (_:))))
        
        updateView()
    }
    
    func updateView(){
        setBtnClicked(btn: btnPrice, clicked: false)
        setBtnClicked(btn: btnSpeed, clicked: false)
        setBtnClicked(btn: btnPlace, clicked: false)
        setBtnClicked(btn: btnRoad, clicked: false)
        setBtnClicked(btn: btnType, clicked: false)
        
        switch selected {
        case .price:
            setBtnClicked(btn: btnPrice, clicked: true)
        case .speed:
            setBtnClicked(btn: btnSpeed, clicked: true)
        case .place:
            setBtnClicked(btn: btnPlace, clicked: true)
        case .road:
            setBtnClicked(btn: btnRoad, clicked: true)
        case .type:
            setBtnClicked(btn: btnType, clicked: true)
        case .none:
            break;
        }
    }
    
    func setBtnClicked(btn: UIButton, clicked: Bool){
        if(!clicked){
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
            btn.layer.backgroundColor = UIColor(named: "background-secondary")?.cgColor
            btn.titleLabel?.tintColor = UIColor(named: "content-on-color")
        } else {
            btn.layer.borderWidth = 0
            btn.layer.backgroundColor = UIColor(named: "content-positive")?.cgColor
            btn.titleLabel?.tintColor = UIColor(named: "background_primary")
        }
    }
    
    @objc func onClickOpen(_ sender:UITapGestureRecognizer){
        delegate?.startFilterSetting()
    }
    
    @IBAction func onClickPrice(_ sender: Any) {
        selected = .price
        updateView()
        showFilterView(type: .price)
    }
    
    @IBAction func onClickSpeed(_ sender: Any) {
        selected = .speed
        updateView()
        showFilterView(type: .speed)
    }
    
    @IBAction func onClickPlace(_ sender: Any) {
        selected = .place
        updateView()
        showFilterView(type: .place)
    }
    
    @IBAction func onClickRoad(_ sender: Any) {
        selected = .road
        updateView()
        showFilterView(type: .road)
    }
    
    @IBAction func onClickType(_ sender: Any) {
        selected = .type
        updateView()
        showFilterView(type: .type)
    }
    
    func showFilterView(type: FilterType){
        delegate?.showFilterContainer(type: type)
    }
}
