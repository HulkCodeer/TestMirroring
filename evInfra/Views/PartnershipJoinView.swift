//
//  PartnershipJoinView.swift
//  evInfra
//
//  Created by SH on 2020/10/05.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import UIKit

class PartnershipJoinView : UIView{
    @IBOutlet weak var view_evinfra_join: UIStackView!
    @IBOutlet weak var view_skrent_join: UIStackView!
    @IBOutlet weak var view_lotte_join: UIStackView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let view = Bundle.main.loadNibNamed("PartnershipJoinView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        addSubview(view)
        initView()
    }
    
    private func initView(){
        let ev_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickEvInfra))
        pinBackground(getBackgroundView(), to: view_evinfra_join)
        view_evinfra_join.addGestureRecognizer(ev_touch)

        let skr_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickEvInfra))
        pinBackground(getBackgroundView(), to: view_skrent_join)
        view_skrent_join.addGestureRecognizer(skr_touch)
        
        let lotte_touch = UITapGestureRecognizer(target: self, action: #selector(self.onClickEvInfra))
        pinBackground(getBackgroundView(), to: view_lotte_join)
        view_lotte_join.addGestureRecognizer(lotte_touch)
    }
    
    @objc func onClickEvInfra(sender: UITapGestureRecognizer){
        print("evinfra btn pressed")
    }
    
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
    }
    
    private func getBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8548362255, green: 0.8549391627, blue: 0.8548011184, alpha: 1)
        view.layer.cornerRadius = 10.0
        return view
    }
    
    
}

public extension UIView {
  public func pin(to view: UIView) {
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
  }
}

protocol PartnershipJoinViewDelegate {
    func addNewPartnership()
    func showEvinfraMembershipInfo()
}
