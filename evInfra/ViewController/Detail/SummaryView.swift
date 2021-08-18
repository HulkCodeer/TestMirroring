//
//  SummaryViewControllerTest.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/08/13.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

class SummaryView: UIView {
    
//    @IBOutlet weak var summaryView: UIView!
//
//    @IBOutlet var stationImg: UIImageView!
//    @IBOutlet var stationNameLb: UILabel!
//    @IBOutlet var favoriteBtn: UIButton!  // btn_main_favorite
//
//    @IBOutlet var shareBtn: UIButton!
//    @IBOutlet var addrLb: UILabel!
//    @IBOutlet var copyBtn: UIButton!
//
//    @IBOutlet var chargerTypeView: UIStackView!
//    @IBOutlet var stateLb: UILabel!
//    @IBOutlet var fastCountLb: UILabel!
//    @IBOutlet var slowCountLb: UILabel!
//    @IBOutlet var filterView: UIStackView!
//
//    @IBOutlet var startBtn: UIButton!
//    @IBOutlet var addBtn: UIButton!
//    @IBOutlet var endBtn: UIButton!
//    @IBOutlet var navigationBtn: UIButton!
    
    public enum SummaryType {
        case Summary
        case DetailSumamry
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        summeryinit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        summeryinit()
//    }
    
    private func summeryinit() {
        let view = Bundle.main.loadNibNamed("SummaryView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
    }
    
    
    
    
//    override func viewWillLayoutSubviews() {
        // btn border
//        self.startPointBtn.setBorderRadius([.bottomLeft, .topLeft], radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
//        self.endPointBtn.setBorderRadius([.bottomRight, .topRight], radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
//        self.naviBtn.setBorderRadius(.allCorners, radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
//        self.addPointBtn.setBorderRadius(.allCorners, radius: 0, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
// self.reportBtn.setBorderRadius(.allCorners, radius: 3, borderColor: UIColor(hex: "#33A2DA"), borderWidth: 1)
        // install round
//        self.indoorView.roundCorners(.allCorners, radius: 3)
//        self.outdoorView.roundCorners(.allCorners, radius: 3)
//        self.canopyView.roundCorners(.allCorners, radius: 3)
        
        // charger power round
//        self.powerView.roundCorners(.allCorners, radius: 3)
//        if isExistAddBtn {
//            self.addPointBtn.isHidden = false
//            self.naviBtn.isHidden = true
//        }else if !isExistAddBtn{
//            self.addPointBtn.isHidden = true
//            self.naviBtn.isHidden = false
//        }
//    }
    
    func initView() {
        let summary:SummaryType = .Summary
        switch summary {
        case .Summary:
            layoutMainSummary()
        case .DetailSumamry:
            layoutDetailSummary()
        }
    }
    
    func layoutMainSummary() {
        
    }
    
    func layoutDetailSummary() {
        
    }
    
    
    // Favorite
//    @IBAction func onClickMainFavorite(_ sender: UIButton) {
//        if MemberManager().isLogin() {
//            let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
//            let favoriteVC:FavoriteViewController = memberStoryboard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
//            favoriteVC.delegate = self
//            self.present(AppSearchBarController(rootViewController: favoriteVC), animated: true, completion: nil)
//        } else {
//            MemberManager().showLoginAlert(vc:self)
//        }
//    }
    
    //    @IBAction func onClickFavorite(_ sender: UIButton) {
    //        bookmark()
    //    }
    //    func bookmark() {
    //        if MemberManager().isLogin() {
    //            ChargerManager.sharedInstance.setFavoriteCharger(charger: self.charger!) { (charger) in
    //                self.setCallOutFavoriteIcon(charger: charger)
    //                if charger.mFavorite {
    //                    Snackbar().show(message: "즐겨찾기에 추가하였습니다.")
    //                } else {
    //                    Snackbar().show(message: "즐겨찾기에서 제거하였습니다.")
    //                }
    //            }
    //        } else {
    //            MemberManager().showLoginAlert(vc: self)
    //        }
    //    }
        
    //    func setCallOutFavoriteIcon(charger: ChargerStationInfo) {
    //        if charger.mFavorite {
    //            self.callOutFavorite.setImage(UIImage(named: "bookmark_on"), for: .normal)
    //        } else {
    //            self.callOutFavorite.setImage(UIImage(named: "bookmark"), for: .normal)
    //        }
    //    }
    
    // Share
    
    // Copy
//    func copy() {
//        UIPasteboard.general.string = addrLb.text
//    }
    
    // [Direction]
    // start
    //    @IBAction func onClickStartPoint(_ sender: Any) {
    //        self.mainViewDelegate?.setStartPoint()
    //        navigationController?.popViewController(animated: true)
    //        dismiss(animated: true, completion: nil)
    //    }
    
    // end
    //    @IBAction func onClickEndPoint(_ sender: Any) {
    //        self.mainViewDelegate?.setEndPoint()
    //        navigationController?.popViewController(animated: true)
    //        dismiss(animated: true, completion: nil)
    //    }
    
    // add
    //    @IBAction func onClickAddPoint(_ sender: Any) {
    //        self.mainViewDelegate?.setStartPath()
    //        navigationController?.popViewController(animated: true)
    //        dismiss(animated: true, completion: nil)
    //    }
    
    // navigation
    //    @IBAction func onClickNavi(_ sender: UIButton) {
    //        if let chargerData = charger {
    //            if let stationDto = chargerData.mStationInfoDto {
    //                let snm = callOutTitle.text ?? ""
    //                let lng = stationDto.mLongitude ?? 0.0
    //                let lat = stationDto.mLatitude ?? 0.0
    //                UtilNavigation().showNavigation(vc: self, snm: snm, lat: lat, lng: lng)
    //            }
    //        }
    //    }
    
}
