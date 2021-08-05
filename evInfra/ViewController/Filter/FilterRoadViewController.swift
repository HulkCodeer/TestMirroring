//
//  FilterRoadViewController.swift
//  evInfra
//
//  Created by SH on 2021/08/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
class FilterRoadViewController: UIViewController {
    @IBOutlet weak var viewGeneral: UIView!
    @IBOutlet weak var viewHighTop: UIView!
    @IBOutlet weak var viewHighDown: UIView!
    
    @IBOutlet weak var ivGeneral: UIImageView!
    @IBOutlet weak var lbGeneral: UILabel!
    @IBOutlet weak var ivHighTop: UIImageView!
    @IBOutlet weak var lbHighTop: UILabel!
    @IBOutlet weak var ivHighDown: UIImageView!
    @IBOutlet weak var lbHighDown: UILabel!
    
    var generalSel = true
    var highTopSel = true
    var highDownSel = true
    
    let bgEnColor: UIColor = UIColor(named: "content-positive")!
    let bgDisColor: UIColor = UIColor(named: "content-tertiary")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        viewGeneral.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickGeneral (_:))))
        viewHighTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickHighTop (_:))))
        viewHighDown.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickHighDown (_:))))
    }
    
    
    @objc func onClickGeneral(_ sender:UITapGestureRecognizer){
        generalSel = !generalSel
        selectItem(index: 0)
    }
    @objc func onClickHighTop(_ sender:UITapGestureRecognizer){
        highTopSel = !highTopSel
        selectItem(index: 1)
    }
    @objc func onClickHighDown(_ sender:UITapGestureRecognizer){
        highDownSel = !highDownSel
        selectItem(index: 2)
    }
    
    func initView(){
        selectItem(index: 0)
        selectItem(index: 1)
        selectItem(index: 2)
    }
    
    func selectItem(index: Int){
        if(index == 0) {
            if (generalSel){
                ivGeneral.tintColor = bgEnColor
                lbGeneral.textColor = bgEnColor
            } else {
                ivGeneral.tintColor = bgDisColor
                lbGeneral.textColor = bgDisColor
            }
        } else if(index == 1) {
            if (highTopSel){
                ivHighTop.tintColor = bgEnColor
                lbHighTop.textColor = bgEnColor
            } else {
                ivHighTop.tintColor = bgDisColor
                lbHighTop.textColor = bgDisColor
            }
        } else if(index == 2) {
            if (highDownSel){
                ivHighDown.tintColor = bgEnColor
                lbHighDown.textColor = bgEnColor
            } else {
                ivHighDown.tintColor = bgDisColor
                lbHighDown.textColor = bgDisColor
            }
        }
    }
}
