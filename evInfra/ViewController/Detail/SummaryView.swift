//
//  SummaryViewControllerTest.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/08/13.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol SummaryDelegate {
    func setCidInfoList()
}

class SummaryView: UIView {
    
    @IBOutlet weak var summaryView: UIView!
    
    @IBOutlet weak var stationImg: UIImageView!
    @IBOutlet weak var stationNameLb: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!  // btn_main_favorite

    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var addrLb: UILabel!
    @IBOutlet weak var copyBtn: UIButton!

    @IBOutlet weak var chargerTypeView: UIStackView!
    @IBOutlet weak var typeDcCombo: UILabel!
    @IBOutlet weak var typeACSam: UILabel!
    @IBOutlet weak var typeDcDemo: UILabel!
    @IBOutlet weak var typeSlow: UILabel!
    @IBOutlet weak var typeSuper: UILabel!
    @IBOutlet weak var typeDestination: UILabel!
    
    @IBOutlet weak var stateLb: UILabel!
    @IBOutlet weak var fastView: UIStackView!
    @IBOutlet weak var slowView: UIStackView!
    @IBOutlet weak var fastCountLb: UILabel!
    @IBOutlet weak var slowCountLb: UILabel!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterPower: UIButton!
    @IBOutlet weak var filterPay: UIButton!
    @IBOutlet weak var filterRoof: UIButton!
    @IBOutlet weak var filterAccess: UIButton!
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var navigationBtn: UIButton!
    
    @IBOutlet weak var stateCountView: UIView!
    @IBOutlet weak var addrView: UIStackView!
    
    var charger:ChargerStationInfo?
    var isAddBtnGone:Bool = false
    var distance: Double = -1.0
    var delegate:SummaryDelegate?
    
    let startKey = "summaryView.start"
    let endKey = "summaryView.end"
    let addKey = "summaryView.add"
    let navigationKey = "summaryView.navigation"
    let loginKey = "summaryView.logIn"
    let favoriteKey = "summaryView.favorite"
    
    var shareUrl = ""
    
    public enum SummaryType {
        case MainSummary
        case DetailSummary
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    // Summary 첫 세팅
    private func initView() {
        let view = Bundle.main.loadNibNamed("SummaryView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
                
        startBtn.layer.cornerRadius = 6
        endBtn.layer.cornerRadius = 6
        addBtn.layer.cornerRadius = 6
        navigationBtn.layer.cornerRadius = 6
    }
    
    // 메인_Sumamry View setting
    func setLayoutType(charger: ChargerStationInfo, type: SummaryType) {
        self.charger = charger
        initLayout(type: type)        
        getStationDetailInfo(type: type)
    }
    
    func initLayout(type: SummaryType) {
        switch type {
        case .MainSummary:
            layoutMainSummary()
        case .DetailSummary:
            layoutDetailSummary()
        }
    }
    
    func layoutMainSummary() {
        if self.charger != nil {
            if let stationDto = self.charger!.mStationInfoDto {
                // 충전소 이미지
                setCompanyIcon(chargerData: self.charger!)
                // 충전소 이름
                stationNameLb.text = stationDto.mSnm
                // 공유하기
                shareBtn.isHidden = true
                // 즐겨찾기
                setCallOutFavoriteIcon(favorite: self.charger!.mFavorite)
                // 충전기 타입
                setChargerType(charger: self.charger!)
                // 충전소 상태
                setStationStatus(charger: self.charger!)
                // 급/완속 카운터 (0/0 -> GONE처리)
                stateCountView.isHidden = false
                fastView.isHidden = false
                slowView.isHidden = false
                let fastPower = charger!.getCountFastPower()
                let slowPower = charger!.getCountSlowPower()
                if !fastPower.isEmpty && !slowPower.isEmpty {
                    if fastPower.equals("0/0"){
                        // Fast GONE
                        fastView.isHidden = true
                    }else if slowPower.equals("0/0"){
                        // Slow GONE
                        slowView.isHidden = true
                    }
                    fastCountLb.text = fastPower
                    slowCountLb.text = slowPower
                }
                // [충전소 필터]
                // 속도
                let powerTitle = self.charger!.getChargerPower(power: self.charger!.mPower, type: (self.charger!.mTotalType)!)
                self.filterPower.setTitle(powerTitle, for: .normal)
                setBerryTag(btn: filterPower)
                // 가격
                setChargePrice(stationDto: self.charger!.mStationInfoDto!)
                setBerryTag(btn: filterPay)
                // 설치형태
                stationArea(stationDto: self.charger!.mStationInfoDto!)
                setBerryTag(btn: filterRoof)
                
                if let limit = self.charger!.mLimit, limit == "Y" {
                    filterAccess.setTitle("비개방", for: .normal)
                } else {
                    filterAccess.setTitle("개방", for: .normal)
                }
                setBerryTag(btn: filterAccess)
                
                // 주소 GONE
                addrView.isHidden = true
                distance = -1.0
                setDistance(charger: self.charger!)
                summaryView.layoutIfNeeded()
            }
        }
    }
    
    // Detail_Summary View setting
    func layoutDetailSummary() {
        addrView.isHidden = false
        if self.charger != nil {
            if let stationDto = self.charger!.mStationInfoDto {
                // 충전소 이미지
                setCompanyIcon(chargerData: self.charger!)
                // 충전소 이름
                stationNameLb.text = stationDto.mSnm
                // 즐겨찾기
                setCallOutFavoriteIcon(favorite: self.charger!.mFavorite)
                // 충전기 타입 GONE
                chargerTypeView.isHidden = true
                // 충전소 상태 GONE
                stateCountView.isHidden = true
                // 필터tag GONE
                filterView.isHidden = true
                // 주소
                var addr = "등록된 정보가 없습니다."
                if stationDto.mAddress != nil && stationDto.mAddressDetail != nil {
                    addr = stationDto.mAddress! + " " + stationDto.mAddressDetail!
                }
                addrLb.text = addr
                // 거리
                setDistance(charger: self.charger!)
                
                summaryView.layoutIfNeeded()
            }
        }
    }
    
    func getStationDetailInfo(type: SummaryType) {
        if self.charger != nil{
            Server.getStationDetail(chargerId:  self.charger!.mChargerId!) { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    let list = json["list"]
                    
                    self.charger!.hasPriceInfo = json["info"].boolValue
                    self.charger!.slowPrice = json["slow"].stringValue
                    self.charger!.fastPrice = json["fast"].stringValue
                    
                    for (_, item):(String, JSON) in list {
                        self.charger!.setStationInfo(jsonList: item)
                        break
                    }
                    // update status
                    self.setStationStatus(charger: self.charger!)
                    if self.charger!.cidInfoList.count > 0 {
                        self.initLayout(type: type)
                        if let delegate = self.delegate {
                            delegate.setCidInfoList()
                            self.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
    
    // 경유지 버튼 visible/gone 관리
    public func layoutAddPathSummary(hiddenAddBtn:Bool) {
        if isAddBtnGone == hiddenAddBtn {
            return // 변경될때만 동작
        }
        var width:CGFloat = 0
        isAddBtnGone = hiddenAddBtn
        if hiddenAddBtn { // visible > gone
            self.addBtn.gone()
            width = self.navigationBtn.bounds.size.width + 48
         } else if !hiddenAddBtn{
            self.addBtn.visible()
            width = self.navigationBtn.bounds.size.width - 48
         }
        // 레이아웃 redraw함수
        self.navigationBtn.bounds.size.width = width
        self.navigationBtn.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    // 즐겨찾기 아이콘
    public func setCallOutFavoriteIcon(favorite: Bool) {
        if favorite {
            self.favoriteBtn.tintColor = UIColor.init(named: "content-warning")
            self.favoriteBtn.setImage(UIImage(named: "icon_star_fill_md"), for: .normal)
        } else {
            self.favoriteBtn.tintColor = UIColor.init(named: "content-primary")
            self.favoriteBtn.setImage(UIImage(named: "icon_star_md"), for: .normal)
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
        if stationDto.mIsPilot ?? false {
            self.filterPay.setTitle("시범운영", for: .normal)
        } else {
            if stationDto.mPay == "Y" {
                self.filterPay.setTitle("유료", for: .normal)
            } else if stationDto.mPay == "N" {
                self.filterPay.setTitle("무료", for: .normal)
            }
        }
    }
    
    func stationArea(stationDto:StationInfoDto) {
        let roof = String(stationDto.mRoof ?? "N")
        var area:String = "실외"
        
        self.filterRoof.gone()
        switch roof {
        case "0":  // outdoor
            self.filterRoof.visible()
            area = "실외"
            break
        case "1":  // indoor
            self.filterRoof.visible()
            area = "실내"
            break
        case "2":  // canopy
            area = "캐노피"
            break
        case "N": // Checking
            break
        default:
            break
        }
        
        self.filterRoof.setTitle(area, for: .normal)
    }
    
    func setChargerType(charger: ChargerStationInfo) {
        guard let chargerType = charger.mTotalType else {
            typeDcDemo.isHidden = true
            typeDcCombo.isHidden = true
            typeACSam.isHidden = true
            typeSlow.isHidden = true
            typeSuper.isHidden = true
            typeDestination.isHidden = true
            return
        }
        // "DC차데모"
        if (chargerType & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
            typeDcDemo.isHidden = false
        } else {
            typeDcDemo.isHidden = true
        }
        
        // "DC콤보"
        if (chargerType & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
            typeDcCombo.isHidden = false
        } else {
            typeDcCombo.isHidden = true
        }
        
        // "AC3상"
        if (chargerType & Const.CTYPE_AC) == Const.CTYPE_AC {
            typeACSam.isHidden = false
        } else {
            typeACSam.isHidden = true
        }

        // "완속"
        if (chargerType & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
            typeSlow.isHidden = false
        } else {
            typeSlow.isHidden = true
        }
        
        // "슈퍼차저"
        if (chargerType & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
            typeSuper.isHidden = false
        } else {
            typeSuper.isHidden = true
        }
        
        // "데스티네이션"
        if (chargerType & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
            typeDestination.isHidden = false
        } else {
            typeDestination.isHidden = true
        }
    }
    
    func setStationStatus(charger:ChargerStationInfo) {
        var status = Const.CHARGER_STATE_UNKNOWN
        if (charger.mTotalStatus != nil){
            status = (charger.mTotalStatus)!
        }
        stateLb.textColor = charger.cidInfo.getCstColor(cst: status)
        stateLb.text = charger.mTotalStatusName
    }
    
    func setBerryTag(btn : UIButton) {
        let bordorColor = UIColor.init(named: "border-opaque")?.cgColor
        btn.layer.borderWidth = 1
        btn.layer.borderColor = bordorColor
        btn.layer.cornerRadius = 12
    }
    
    // Copy
    @IBAction func copyAddr(_ sender: Any) {
        UIPasteboard.general.string = addrLb.text
        Snackbar().show(message: "주소가 복사되었습니다.")
    }
    
    // [Summary]
    // share
    @IBAction func onClickShare(_ sender: Any) {
        let linkManager = LinkShareManager.shared
        linkManager.sendToKakao(with: charger)
    }
    
    // Favorite
    @IBAction func onClickFavorite(_ sender: UIButton) {
        if MemberManager().isLogin() {
            if self.charger != nil {
                self.favorite()
            }
        } else {
            let logIn = Notification.Name(rawValue: loginKey)
            NotificationCenter.default.post(name: logIn, object: nil)
        }
    }
    
    // [Direction]
    // start
    @IBAction func onClickStartPoint(_ sender: Any) {
        let start = Notification.Name(rawValue: startKey)
        NotificationCenter.default.post(name: start, object: charger)
    }
    // end
    @IBAction func onClickEndPoint(_ sender: Any) {
        let end = Notification.Name(rawValue: endKey)
        NotificationCenter.default.post(name: end, object: charger)
    }
    // add
    @IBAction func onClickAddPoint(_ sender: Any) {
        let add = Notification.Name(rawValue: addKey)
        NotificationCenter.default.post(name: add, object: charger)
    }
    // navigation
    @IBAction func onClickNavi(_ sender: UIButton) {
        let navigation = Notification.Name(rawValue: navigationKey)
        NotificationCenter.default.post(name: navigation, object: charger)
    }

    func favorite() {
        if self.charger != nil {
            ChargerManager.sharedInstance.setFavoriteCharger(charger: self.charger!) { (charger) in
                if charger.mFavorite {
                    Snackbar().show(message: "즐겨찾기에 추가하였습니다.")
                } else {
                    Snackbar().show(message: "즐겨찾기에서 제거하였습니다.")
                }
                self.setCallOutFavoriteIcon(favorite: charger.mFavorite)
                
                let favorite = Notification.Name(rawValue: self.favoriteKey)
                NotificationCenter.default.post(name: favorite, object: charger.mFavorite)
            }
        }
    }
    
    func setDistance(charger: ChargerStationInfo) {
        guard self.distance < 0 else {
            // detail에서 여러번 불리는것 방지
            self.navigationBtn.setTitle(" \(self.distance) Km 안내 시작", for: .normal)
            return
        }
        
        fetchDistance(destination: (charger.mStationInfoDto?.mLatitude ?? 0.0, charger.mStationInfoDto?.mLongitude ?? 0.0))
    }
    
    internal func fetchDistance(destination: (Double, Double)) {
        let lat = destination.0
        let lng = destination.1
        
        guard lat != .zero || lng != .zero else {
            DispatchQueue.main.async {
                self.navigationBtn.setTitle("계산중", for: .normal)
            }
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let distance = CLLocationCoordinate2D()
                .distance(to: CLLocationCoordinate2D(latitude: lat, longitude: lng))
            self.distance = round(distance / 1000 * 10) / 10
            
            if distance > .zero {
                DispatchQueue.main.async {
                    self.navigationBtn.setTitle(" \(self.distance) Km 안내 시작", for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationBtn.setTitle("계산중", for: .normal)
                }
            }
        }
    }
    
    internal func getDistance(curPos: TMapPoint, desPos: TMapPoint) {
        if desPos.getLatitude() == 0 || desPos.getLongitude() == 0 {
            self.navigationBtn.setTitle("계산중", for: .normal)
        } else {
            DispatchQueue.global(qos: .background).async {
                let tMapPathData = TMapPathData.init()
                if let path = tMapPathData.find(from: curPos, to: desPos) {
                    self.distance = round(path.getDistance() / 1000 * 10) / 10

                    DispatchQueue.main.async {
                        self.navigationBtn.setTitle(" \(self.distance) Km 안내 시작", for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationBtn.setTitle("계산중", for: .normal)
                    }
                }
            }
        }
    }
}

