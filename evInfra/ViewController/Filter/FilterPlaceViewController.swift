//
//  FilterPlaceViewController.swift
//  evInfra
//
//  Created by SH on 2021/08/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
class FilterPlaceViewController: UIViewController {
    @IBOutlet weak var viewIndoor: UIView!
    @IBOutlet weak var viewOutdoor: UIView!
    @IBOutlet weak var viewCanopy: UIView!
    
    @IBOutlet weak var ivIndoor: UIImageView!
    @IBOutlet weak var lbIndoor: UILabel!
    @IBOutlet weak var ivOutdoor: UIImageView!
    @IBOutlet weak var lbOutdoor: UILabel!
    @IBOutlet weak var ivCanopy: UIImageView!
    @IBOutlet weak var lbCanopy: UILabel!
    
    var indoorSel = true
    var outDoorSel = true
    var canopySel = true
    
    let bgEnColor: UIColor = UIColor(named: "content-positive")!
    let bgDisColor: UIColor = UIColor(named: "content-tertiary")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        viewIndoor.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickIndoor (_:))))
        viewOutdoor.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickOutdoor (_:))))
        viewCanopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector (self.onClickCanopy (_:))))
    }
    
    
    @objc func onClickIndoor(_ sender:UITapGestureRecognizer){
        indoorSel = !indoorSel
        selectItem(index: 0)
    }
    @objc func onClickOutdoor(_ sender:UITapGestureRecognizer){
        outDoorSel = !outDoorSel
        selectItem(index: 1)
    }
    @objc func onClickCanopy(_ sender:UITapGestureRecognizer){
        canopySel = !canopySel
        selectItem(index: 2)
    }
    
    func initView(){
        selectItem(index: 0)
        selectItem(index: 1)
        selectItem(index: 2)
    }
    
    func selectItem(index: Int){
        if(index == 0) {
            if (indoorSel){
                ivIndoor.tintColor = bgEnColor
                lbIndoor.textColor = bgEnColor
            } else {
                ivIndoor.tintColor = bgDisColor
                lbIndoor.textColor = bgDisColor
            }
        } else if(index == 1) {
            if (outDoorSel){
                ivOutdoor.tintColor = bgEnColor
                lbOutdoor.textColor = bgEnColor
            } else {
                ivOutdoor.tintColor = bgDisColor
                lbOutdoor.textColor = bgDisColor
            }
        } else if(index == 2) {
            if (canopySel){
                ivCanopy.tintColor = bgEnColor
                lbCanopy.textColor = bgEnColor
            } else {
                ivCanopy.tintColor = bgDisColor
                lbCanopy.textColor = bgDisColor
            }
        }
    }
}
