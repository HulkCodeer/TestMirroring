//
//  FilterAccessViewController.swift
//  evInfra
//
//  Created by SH on 2021/08/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
class FilterAccessViewController: UIViewController {
    @IBOutlet weak var viewPublic: UIView!
    @IBOutlet weak var viewNonPublic: UIView!
    
    @IBOutlet weak var ivPublic: UIImageView!
    @IBOutlet weak var lbPublic: UILabel!
    @IBOutlet weak var ivNonPublic: UIImageView!
    @IBOutlet weak var lbNonPublic: UILabel!
    
    var publicSel = true
    var nonPublicSel = false
    
    let bgEnColor: UIColor = UIColor(named: "content-positive")!
    let bgDisColor: UIColor = UIColor(named: "content-tertiary")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        viewPublic.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickPublic (_:))))
        viewNonPublic.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickNonPublic (_:))))
    }
    
    
    @objc func onClickPublic(_ sender:UITapGestureRecognizer){
        publicSel = !publicSel
        selectItem(index: 0)
    }
    @objc func onClickNonPublic(_ sender:UITapGestureRecognizer){
        nonPublicSel = !nonPublicSel
        selectItem(index: 1)
    }
    
    func initView(){
        selectItem(index: 0)
        selectItem(index: 1)
    }
    
    func selectItem(index: Int){
        if(index == 0) {
            if (publicSel){
                ivPublic.tintColor = bgEnColor
                lbPublic.textColor = bgEnColor
            } else {
                ivPublic.tintColor = bgDisColor
                lbPublic.textColor = bgDisColor
            }
        } else if(index == 1) {
            if (nonPublicSel){
                ivNonPublic.tintColor = bgEnColor
                lbNonPublic.textColor = bgEnColor
            } else {
                ivNonPublic.tintColor = bgDisColor
                lbNonPublic.textColor = bgDisColor
            }
        }
    }
}
