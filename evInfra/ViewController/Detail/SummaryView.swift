//
//  SummaryViewControllerTest.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/08/13.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

class SummaryView: UIView {
    
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet var summaryContentView: UIStackView!
    
    @IBOutlet var stationImg: UIImageView!
    @IBOutlet var stationNameLb: UILabel!
    @IBOutlet var favoriteBtn: UIButton!  // btn_main_favorite

    @IBOutlet var shareBtn: UIButton!
    @IBOutlet var addrLb: UILabel!
    @IBOutlet var copyBtn: UIButton!

    @IBOutlet var chargerTypeView: UIStackView!
    @IBOutlet var typeDcCombo: UILabel!
    @IBOutlet var typeACSam: UILabel!
    @IBOutlet var typeDcDemo: UILabel!
    @IBOutlet var typeSlow: UILabel!
    @IBOutlet var typeSuper: UILabel!
    @IBOutlet var typeDestination: UILabel!
    
    @IBOutlet var stateLb: UILabel!
    @IBOutlet var fastCountLb: UILabel!
    @IBOutlet var slowCountLb: UILabel!
    
    @IBOutlet var filterView: UIStackView!
    @IBOutlet var filterPower: UILabel!
    @IBOutlet var filterPay: UILabel!
    @IBOutlet var filterRoof: UILabel!

    @IBOutlet var startBtn: UIButton!
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var endBtn: UIButton!
    @IBOutlet var navigationBtn: UIButton!
    
    @IBOutlet var stateCountView: UIView!
    @IBOutlet var testView: UIStackView!
    @IBOutlet var navigationView: UIStackView!
    @IBOutlet var addrView: UIStackView!
    
    
    public var charger: ChargerStationInfo!
    
    var mainViewDelegate: MainViewDelegate?
    var detailViewDelegate: DetailViewDelegate?
    var cidList = [CidInfo]()
    var cidListData:JSON!
    
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
        
        filterView.isHidden = true
        addrView.isHidden = false
        
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
                setStationCstColor(charger: charger)
                // 급/완속 카운터
                stateCountView.isHidden = false
                let count = countFastPower(charger: charger)
//                print("csj_", "count : ", count)

                // 충전기 타입
                setChargerType(charger: charger)
                
                // [충전소 필터]
                // 속도
                filterView.isHidden = false
                self.filterPower.text = charger.getChargerPower(power: (charger.mPower)!, type: (charger.mTotalType)!)
                filterPower.setBerryTag()
                // 가격
                setChargePrice(stationDto: charger.mStationInfoDto!)
                filterPay.setBerryTag()
                // 설치형태
                stationArea(stationDto: charger.mStationInfoDto!)
                filterRoof.setBerryTag()
                
                // 주소 View Gone
                addrView.isHidden = true
                
                summaryView.layoutIfNeeded()
            }
        }
    }
    
    public func countFastPower(charger:ChargerStationInfo) -> Int{
        let count = charger.cidInfo
        print("csj_", "cidInfoTest : ", count)
//        var fast:Int = 0
//        if charger.cidInfo.chargerType == Const.CHARGER_TYPE_SLOW || charger.cidInfo.chargerType == Const.CHARGER_TYPE_DESTINATION{
//            fast = fast+1
//        }
//        return fast
        return 0
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
                
                
                chargerTypeView.isHidden = true
                stateCountView.isHidden = true
                filterView.isHidden = true
                
                summaryView.layoutIfNeeded()
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
    
    func setChargePrice(stationDto: StationInfoDto) {
        switch stationDto.mPay {
            case "Y":
                self.filterPay.text = "유료"
            case "N":
                self.filterPay.text = "무료"
            default:
                self.filterPay.text = "시범운영"
        }
    }
    
    func stationArea(stationDto:StationInfoDto) {
        let roof = String(stationDto.mRoof ?? "N")
        var area:String = "실외"
        self.filterRoof.isHidden = false
        switch roof {
        case "0":  // outdoor
            area = "실외"
            break
        case "1":  // indoor
            area = "실내"
            break
        case "2":  // canopy
            area = "캐노피"
            break
        case "N": // Checking
            self.filterRoof.isHidden = true
            break
        default:
            self.filterRoof.isHidden = true
            break
        }
        self.filterRoof.text = area
        self.filterRoof.textColor = UIColor.init(named:"content-parimary")
    }
    
    func setChargerType(charger:ChargerStationInfo) {
        typeDcCombo.isHidden = true
        typeACSam.isHidden = true
        typeDcDemo.isHidden = true
        typeSlow.isHidden = true
        typeSuper.isHidden = true
        typeDestination.isHidden = true
        switch charger.mTotalType {
        case Const.CHARGER_TYPE_DCCOMBO:
            typeDcCombo.isHidden = false
            break
        case Const.CHARGER_TYPE_DCCOMBO_AC:
            typeDcCombo.isHidden = false
            typeACSam.isHidden = false
            break
        case Const.CHARGER_TYPE_AC:
            typeACSam.isHidden = false
            break
        case Const.CHARGER_TYPE_DCDEMO:
            typeDcDemo.isHidden = false
            break
        case Const.CHARGER_TYPE_DCDEMO_AC:
            typeDcDemo.isHidden = false
            typeACSam.isHidden = false
            break
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO:
            typeDcDemo.isHidden = false
            typeDcCombo.isHidden = false
            break
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO_AC:
            typeDcDemo.isHidden = false
            typeDcCombo.isHidden = false
            typeACSam.isHidden = false
            break
        case Const.CHARGER_TYPE_SLOW:
            typeSlow.isHidden = false
            break
        case Const.CHARGER_TYPE_SUPER_CHARGER:
            typeSuper.isHidden = false
            break
        case Const.CHARGER_TYPE_DESTINATION:
            typeDestination.isHidden = false
            break
        default:
            break
        }
    }
    
    func setStationCstColor(charger:ChargerStationInfo) {
        var status = Const.CHARGER_STATE_UNKNOWN
        if (charger.mTotalStatus != nil){
            status = (charger.mTotalStatus)!
        }
        stateLb.textColor = charger.cidInfo.getCstColor(cst: status)
    }
    
    func setCidInfo(jsonList: JSON) {
        print("csj_", "json", jsonList)
        cidListData = jsonList
        
        let clist = jsonList["cl"]
        
        for (_, item):(String, JSON) in clist {
            let cidInfo = CidInfo.init(cid: item["cid"].stringValue, chargerType: item["tid"].intValue, cst: item["cst"].stringValue, recentDate: item["rdt"].stringValue, power: item["p"].intValue)
            print("csj_", "test", cidInfo.power)
            cidList.append(cidInfo)
        }
        
        if !cidList.isEmpty {
            var stationSt = cidList[0].status!
            for cid in cidList {
                if (stationSt != cid.status) {
                    if(cid.status == Const.CHARGER_STATE_WAITING) {
                        stationSt = cid.status!
                        break
                    }
                }
            }
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
