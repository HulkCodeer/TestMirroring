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
    @IBOutlet weak var fastCountLb: UILabel!
    @IBOutlet weak var slowCountLb: UILabel!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterPower: UIButton!
    @IBOutlet weak var filterPay: UIButton!
    @IBOutlet weak var filterRoof: UIButton!
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var navigationBtn: UIButton!
    
    @IBOutlet weak var stateCountView: UIView!
    @IBOutlet weak var addrView: UIStackView!
    
    
    public var charger: ChargerStationInfo!
    
    var mainViewDelegate: MainViewDelegate?
    var detailViewDelegate: DetailViewDelegate?
    var detailData = DetailStationData()
    var isAddBtnGone:Bool = false
    var distance: Double = -1.0
    
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
                
        // navigationBtn.layer.cornerRadius = 6
        startBtn.layer.cornerRadius = 6
        endBtn.layer.cornerRadius = 6
        addBtn.layer.cornerRadius = 6
        navigationBtn.layer.cornerRadius = 6
    }
    // 메인_Sumamry View setting
    func layoutMainSummary() {
        if charger != nil {
            if let stationDto = charger.mStationInfoDto {
                // 충전소 이름
                stationNameLb.text = stationDto.mSnm
                // 충전소 이미지
                setCompanyIcon(chargerData: charger)
            
                shareBtn.isHidden = true
                
                setCallOutFavoriteIcon(favorite: charger.mFavorite)
                
                // 충전소 상태
                stateLb.text = charger.mTotalStatusName
                setStationCstColor(charger: charger)
                // 급/완속 카운터
                stateCountView.isHidden = false
                let fastPower = detailData.getCountFastPower()
                let slowPower = detailData.getCountSlowPower()
                fastCountLb.textColor = UIColor.init(named: "content-primary")
                slowCountLb.textColor = UIColor.init(named: "content-primary")
                if !fastPower.isEmpty && !slowPower.isEmpty {
                    if fastPower.equals("0/0"){
                        fastCountLb.textColor = UIColor.init(named: "content-tertiary")
                    }else if slowPower.equals("0/0"){
                        slowCountLb.textColor = UIColor.init(named: "content-tertiary")
                    }
                    fastCountLb.text = fastPower
                    slowCountLb.text = slowPower
                }
                
                // 충전기 타입
                setChargerType(charger: charger)
                // [충전소 필터]
                // 속도
                let bordorColor = UIColor.init(named: "border-opaque")?.cgColor
                filterView.isHidden = false
                
                let powerTitle = charger.getChargerPower(power: (charger.mPower)!, type: (charger.mTotalType)!)
                self.filterPower.setTitle(powerTitle, for: .normal)
                filterPower.layer.borderWidth = 1
                filterPower.layer.borderColor = bordorColor
                filterPower.layer.cornerRadius = 12
                // 가격
                setChargePrice(stationDto: charger.mStationInfoDto!)
                filterPay.layer.borderWidth = 1
                filterPay.layer.borderColor = bordorColor
                filterPay.layer.cornerRadius = 12
                
                // 설치형태
                stationArea(stationDto: charger.mStationInfoDto!)
                filterRoof.layer.borderWidth = 1
                filterRoof.layer.borderColor = bordorColor
                filterRoof.layer.cornerRadius = 12
                
                // 주소 View Gone
                addrView.isHidden = true
                
                setDistance()
                
                summaryView.layoutIfNeeded()
            }
        }
    }
    
    // Detail_Summary View setting
    func layoutDetailSummary() {
        addrView.isHidden = false
        if charger != nil {
            if let stationDto = charger.mStationInfoDto {
                // 충전소 이름
                stationNameLb.text = stationDto.mSnm
                // 충전소 이미지
                setCompanyIcon(chargerData: charger)
                
                setCallOutFavoriteIcon(favorite: charger.mFavorite)
                // 주소
                var addr = "등록된 정보가 없습니다."
                if stationDto.mAddress != nil && stationDto.mAddressDetail != nil {
                    addr = stationDto.mAddress! + " " + stationDto.mAddressDetail!
                }
                addrLb.text = addr
                
                
                chargerTypeView.isHidden = true
                stateCountView.isHidden = true
                filterView.isHidden = true
                
                setDistance()
                
                summaryView.layoutIfNeeded()
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
        switch stationDto.mPay {
            case "Y":
                self.filterPay.setTitle("유료", for: .normal)
            case "N":
                self.filterPay.setTitle("무료", for: .normal)
            default:
                self.filterPay.setTitle("시범운영", for: .normal)
        }
    }
    
    func stationArea(stationDto:StationInfoDto) {
        let roof = String(stationDto.mRoof ?? "N")
        var area:String = "실외"
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
            area = "확인중"
            break
        default:
            self.filterRoof.gone()
            break
        }
        
        self.filterRoof.setTitle(area, for: .normal)
    }
    
    func setChargerType(charger:ChargerStationInfo) {
        // "DC차데모"
        if (charger.mTotalType! & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
            self.typeDcDemo.isHidden = false
        } else {
            self.typeDcDemo.isHidden = true
        }
        
        // "DC콤보"
        if (charger.mTotalType! & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
            self.typeDcCombo.isHidden = false
        } else {
            self.typeDcCombo.isHidden = true
        }
        
        // "AC3상"
        if (charger.mTotalType! & Const.CTYPE_AC) == Const.CTYPE_AC {
            self.typeACSam.isHidden = false
        } else {
            self.typeACSam.isHidden = true
        }

        // "완속"
        if (charger.mTotalType! & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
            self.typeSlow.isHidden = false
        } else {
            self.typeSlow.isHidden = true
        }
        
        // "슈퍼차저"
        if (charger.mTotalType! & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
            self.typeSuper.isHidden = false
        } else {
            self.typeSuper.isHidden = true
        }
        
        // "데스티네이션"
        if (charger.mTotalType! & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
            self.typeDestination.isHidden = false
        } else {
            self.typeDestination.isHidden = true
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
        
        let clist = jsonList["cl"]
        var cidList = [CidInfo]()
        
        for (_, item):(String, JSON) in clist {
            let cidInfo = CidInfo.init(cid: item["cid"].stringValue, chargerType: item["tid"].intValue, cst: item["cst"].stringValue, recentDate: item["rdt"].stringValue, power: item["p"].intValue)
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
            detailData.status = stationSt
        }
    }
    
    // [Summary]
    // share
    @IBAction func onClickShare(_ sender: Any) {
        detailViewDelegate?.onShare()
    }
    // Favorite
    @IBAction func onClickFavorite(_ sender: UIButton) {
        if mainViewDelegate != nil {
            mainViewDelegate?.setFavorite{ (isFavorite) in
                self.setCallOutFavoriteIcon(favorite: isFavorite)
            }
        }
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

    
    func setDistance() {
        if self.distance < 0 {
            if let currentLocation = MainViewController.currentLocation {
                getDistance(curPos: currentLocation, desPos: self.charger!.marker.getTMapPoint())
            } else {
                self.navigationBtn.setTitle("계산중", for: .normal)
            }
        } else {
            self.navigationBtn.setTitle("\(self.distance) Km 안내 시작", for: .normal)
        }
    }

    func getDistance(curPos: TMapPoint, desPos: TMapPoint) {
        if desPos.getLatitude() == 0 || desPos.getLongitude() == 0 {
            self.navigationBtn.setTitle("계산중", for: .normal)
        } else {
            self.navigationBtn.setTitle("확인중", for: .normal)
            DispatchQueue.global(qos: .background).async {
                let tMapPathData = TMapPathData.init()
                if let path = tMapPathData.find(from: curPos, to: desPos) {
                    self.distance = round(path.getDistance() / 1000 * 10) / 10

                    DispatchQueue.main.async {
                        self.navigationBtn.setTitle("\(self.distance) Km 안내 시작", for: .normal)
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

