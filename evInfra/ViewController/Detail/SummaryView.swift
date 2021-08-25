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
    
    @IBOutlet var stateCountView: UIView!
    @IBOutlet var testView: UIStackView!
    @IBOutlet var navigationView: UIStackView!
    
    public var charger: ChargerStationInfo!
    
    var mainViewDelegate: MainViewDelegate?
    var detailViewDelegate: DetailViewDelegate?
    
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
        layoutMainSummary()
    }
    // Summary 첫 세팅
    private func summeryinit() {
        let view = Bundle.main.loadNibNamed("SummaryView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        layoutAddPathSummary(hiddenAddBtn: false)
        
        startBtn.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 6)
        endBtn.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 6)
        addBtn.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 6)
        navigationBtn.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 6)
    }
    // 메인_Sumamry View setting
    func layoutMainSummary() {
        if charger != nil {
            if let stationDto = charger.mStationInfoDto {
                // 충전소 이름
                stationNameLb.text = stationDto.mSnm
                // 충전소 이미지
                setCompanyIcon(chargerData: charger)
                // 주소
                var addr = "등록된 정보가 없습니다."
                if stationDto.mAddress != nil && stationDto.mAddressDetail != nil {
                    addr = stationDto.mAddress! + " " + stationDto.mAddressDetail!
                }
                addrLb.text = addr
                // 충전소 상태
                stateLb.text = charger.mTotalStatusName
                // 급/완속 카운터
                stateCountView.isHidden = false
//                var powerFast = CidInfo.countFastPower()
                
                // [충전소 필터]
                // 속도
                let powerView:UILabel = UILabel.init()
                powerView.text = charger.mPowerSt
                filterView.addSubview(powerView)
                // 가격
                let payView:UILabel = UILabel.init()
                payView.text = charger.mStationInfoDto?.mPay
                filterView.addSubview(payView)
                // 설치형태
                let roofView:UILabel = UILabel.init()
                roofView.text = charger.mStationInfoDto?.mRoof
                filterView.addSubview(roofView)
                filterView.isHidden = false
            }
        }
    }
    // Detail_Summary View setting
    func layoutDetailSummary() {
        if charger != nil {
            if let stationDto = charger.mStationInfoDto {
                // 충전소 이름
                stationNameLb.text = stationDto.mSnm
                // 충전소 이미지
                setCompanyIcon(chargerData: charger)
                // 주소
                var addr = "등록된 정보가 없습니다."
                if stationDto.mAddress != nil && stationDto.mAddressDetail != nil {
                    addr = stationDto.mAddress! + " " + stationDto.mAddressDetail!
                }
                addrLb.text = addr
            }
        }
    }
    // 경유지 버튼 visible/gone 관리
    public func layoutAddPathSummary(hiddenAddBtn:Bool) {
        if hiddenAddBtn && !self.addBtn.isHidden{
            self.addBtn.isHidden = true
            self.addBtn.gone()
        } else if !hiddenAddBtn{
            self.addBtn.isHidden = false
        }
        // 레이아웃 redraw함수
        self.layoutIfNeeded()
//        self.setNeedsDisplay()
//        self.setNeedsUpdateConstraints()
    }
    
    // 즐겨찾기 아이콘
    public func setCallOutFavoriteIcon(charger: ChargerStationInfo) {
        if charger.mFavorite {
            self.favoriteBtn.tintColor = UIColor.init(named: "content-warning")
            self.favoriteBtn.setImage(UIImage(named: "bookmark_on"), for: .normal)
        } else {
            self.favoriteBtn.tintColor = UIColor.init(named: "content-primary")
            self.favoriteBtn.setImage(UIImage(named: "bookmark"), for: .normal)
        }
    }
    
    func setCompanyIcon(chargerData: ChargerStationInfo) {
        if chargerData.getCompanyIcon() != nil{
            self.stationImg.image = chargerData.getCompanyIcon()
        }else {
            self.stationImg.image = UIImage(named: "icon_building_sm")
        }
    }
    
    // [Summary]
    // share
    @IBAction func onClickShare(_ sender: Any) {
        detailViewDelegate?.onShare()
    }
    // Favorite
    @IBAction func onClickFavorite(_ sender: UIButton) {
        detailViewDelegate?.onFavorite()
    }
    // Copy
    @IBAction func copyAddr(_ sender: Any) {
        UIPasteboard.general.string = addrLb.text
        Snackbar().show(message: "주소가 복사되었습니다.")
    }
    
    // [Direction]
    // start
    @IBAction func onClickStartPoint(_ sender: Any) {
        if mainViewDelegate != nil {
            mainViewDelegate?.setStartPoint()
        }
        detailViewDelegate?.onStart()
    }
    // end
    @IBAction func onClickEndPoint(_ sender: Any) {
        if mainViewDelegate != nil {
            mainViewDelegate?.setEndPoint()
            mainViewDelegate?.setStartPath()
        }
        detailViewDelegate?.onEnd()
    }
    // add
    @IBAction func onClickAddPoint(_ sender: Any) {
        if mainViewDelegate != nil {
            mainViewDelegate?.setStartPath()
        }
        detailViewDelegate?.onAdd()
    }
    // navigation
    @IBAction func onClickNavi(_ sender: UIButton) {
        if mainViewDelegate != nil {
            mainViewDelegate?.setNavigation()
        }
        detailViewDelegate?.onNavigation()
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


//    func setDistance() {
//        if let currentLocatin = MainViewController.currentLocation {
//            getDistance(curPos: currentLocatin, desPos: self.selectCharger!.marker.getTMapPoint())
//        } else {
//            self.distanceLb.text = "현재 위치를 받아오지 못했습니다."
//        }
//    }
//
//    func getDistance(curPos: TMapPoint, desPos: TMapPoint) {
//        if desPos.getLatitude() == 0 || desPos.getLongitude() == 0 {
//            self.distanceLb.text = "현재 위치를 받아오지 못했습니다."
//        } else {
//            self.distanceLb.text = "계산중"
//
//            DispatchQueue.global(qos: .background).async {
//                let tMapPathData = TMapPathData.init()
//                if let path = tMapPathData.find(from: curPos, to: desPos) {
//                    let distance = Double(path.getDistance() / 1000).rounded()
//
//                    DispatchQueue.main.async {
//                        self.distanceLb.text = "| \(distance) Km"
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        self.distanceLb.text = "계산오류."
//                    }
//                }
//            }
//        }
//    }
