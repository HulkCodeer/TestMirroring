//
//  SummaryViewControllerTest.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/08/13.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation

class SummaryView: UIView {
    
    @IBOutlet weak var summaryView: UIView!

    @IBOutlet var stationImg: UIImageView!
    @IBOutlet var stationNameLb: UILabel!
    @IBOutlet var favoriteBtn: UIButton!  // btn_main_favorite

    @IBOutlet var shareBtn: UIButton!
    @IBOutlet var addrLb: UILabel!
    @IBOutlet var copyBtn: UIButton!

    @IBOutlet var chargerTypeView: UIStackView!
    @IBOutlet var stateLb: UILabel!
    @IBOutlet var fastCountLb: UILabel!
    @IBOutlet var slowCountLb: UILabel!
    @IBOutlet var filterView: UIStackView!

    @IBOutlet var startBtn: UIButton!
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var endBtn: UIButton!
    @IBOutlet var navigationBtn: UIButton!
    
    var mainViewDelegate: MainViewDelegate?
    var charger: ChargerStationInfo?
    var uIVC: UIViewController?
    
    public enum SummaryType {
        case Summary
        case DetailSumamry
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    func initView() {
        summeryinit()
        let summary:SummaryType = .Summary
        switch summary {
        case .Summary:
            layoutMainSummary()
        case .DetailSumamry:
            layoutDetailSummary()
        }
    }
    
    private func summeryinit() {
        let view = Bundle.main.loadNibNamed("SummaryView", owner: self, options: nil)?.first as! UIView
        print("csj_", "bouns.width : ", bounds.width)
        print("csj_", "view.width : ", view.frame.width)
        view.frame = bounds
        addSubview(view)
        
        startBtn.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 6)
        endBtn.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 6)
        addBtn.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 6)
        navigationBtn.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 6)
    }
    
    func layoutMainSummary() {
        
    }
    
    func layoutDetailSummary() {
        
    }
    
    
    func setChargerData(stationInfo:ChargerStationInfo) {
        // delegate 필요
        self.charger = stationInfo
    }
    
    func setVC(uiVC:UIViewController) {
        self.uIVC = uiVC
    }
    
    // Copy
    @IBAction func copyAddr(_ sender: Any) {
        UIPasteboard.general.string = addrLb.text
        Snackbar().show(message: "주소가 복사되었습니다.")
    }
    
    // [Direction]
    // start
        @IBAction func onClickStartPoint(_ sender: Any) {
            self.mainViewDelegate?.setStartPoint()
            // 밑 사항은 VC 에서 처리하도록 새로운 delegate가 필요함
            if let uiVC = self.uIVC{
                uiVC.navigationController?.popViewController(animated: true)
                uiVC.dismiss(animated: true, completion: nil)
            }
        }
    
    // end
        @IBAction func onClickEndPoint(_ sender: Any) {
            self.mainViewDelegate?.setEndPoint()
            if let uiVC = self.uIVC {
                uiVC.navigationController?.popViewController(animated: true)
                uiVC.dismiss(animated: true, completion: nil)
            }
        }
    
    // add
        @IBAction func onClickAddPoint(_ sender: Any) {
            self.mainViewDelegate?.setStartPath()
            if let uiVC = self.uIVC {
                uiVC.navigationController?.popViewController(animated: true)
                uiVC.dismiss(animated: true, completion: nil)
            }
        }
    
    // navigation
        @IBAction func onClickNavi(_ sender: UIButton) {
            if let chargerData = charger {
                if let stationDto = chargerData.mStationInfoDto {
                    if let vc = self.uIVC {
                        let snm = stationNameLb.text ?? ""
                        let lng = stationDto.mLongitude ?? 0.0
                        let lat = stationDto.mLatitude ?? 0.0
                        UtilNavigation().showNavigation(vc: vc, snm: snm, lat: lat, lng: lng)
                    }
                }
            }
        }
    
    
    @IBAction func onClickFavorite(_ sender: UIButton) {
        bookmark()
    }
    
    func bookmark() {
        if let chargerData = self.charger {
            if MemberManager().isLogin() {
                ChargerManager.sharedInstance.setFavoriteCharger(charger: chargerData) { (charger) in
                    self.setCallOutFavoriteIcon(charger: charger)
                    if charger.mFavorite {
                        Snackbar().show(message: "즐겨찾기에 추가하였습니다.")
                    } else {
                        Snackbar().show(message: "즐겨찾기에서 제거하였습니다.")
                    }
                }
            } else {
                if let uiVC = self.uIVC {
                    MemberManager().showLoginAlert(vc: uiVC)
                }
            }
        }
    }
        
    func setCallOutFavoriteIcon(charger: ChargerStationInfo) {
        if charger.mFavorite {
            self.favoriteBtn.setImage(UIImage(named: "bookmark_on"), for: .normal)
        } else {
            self.favoriteBtn.setImage(UIImage(named: "bookmark"), for: .normal)
        }
    }
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
