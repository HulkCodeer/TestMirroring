//
//  ViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import DropDown
import Material
import M13Checkbox
import SwiftyJSON

protocol MainViewDelegate {
    func redrawCalloutLayer()
    func setStartPath()         // 경로찾기(시작)
    func setStartPoint()        // 경로찾기(출발)
    func setEndPoint()          // 경로찾기(도착)
}

class MainViewController: UIViewController {

    // constant
    let ROUTE_START = 0
    let ROUTE_END   = 1
    
    // user Default
    let defaults = UserDefault()
    
    
    @IBOutlet var rootView: UIView!
    
    // Map View
    @IBOutlet weak var mapContainerView: UIView!
    
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var reNewButton: UIButton!
    @IBOutlet weak var btnChargePrice: UIButton!
    
    // Indicator View
    @IBOutlet weak var markerIndicator: UIActivityIndicatorView!
    
    // Filter View
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var routeView: UIView!
    
    @IBOutlet weak var startField: TextField!
    @IBOutlet weak var endField: TextField!
    
    @IBOutlet weak var btnRouteCancel: UIButton!
    @IBOutlet weak var btnRoute: UIButton!
    
    @IBOutlet weak var btnWay: UIButton!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var btnRegion: UIButton!
    @IBOutlet weak var btnCompany: UIButton!
    
    @IBOutlet weak var cbDcDemo: M13Checkbox!
    @IBOutlet weak var svDcDemo: UIView!
    
    @IBOutlet weak var cbAc3: M13Checkbox!
    @IBOutlet weak var svAc3: UIView!
    
    @IBOutlet weak var cbDcCombo: M13Checkbox!
    @IBOutlet weak var svDcCombo: UIView!
    
    @IBOutlet weak var cbSuper: M13Checkbox!
    @IBOutlet weak var svSuper: UIView!
    
    @IBOutlet weak var cbSlow: M13Checkbox!
    @IBOutlet weak var svSlow: UIView!
    
    // Callout View
    @IBOutlet weak var callOutLayer: UIView!
    // Menu Button Layer
    @IBOutlet var btn_menu_layer: UIView!
    @IBOutlet var btn_main_charge: UIButton!
    @IBOutlet var btn_main_offerwall: UIButton!
    @IBOutlet var btn_main_help: UIButton!
    @IBOutlet var btn_main_favorite: UIButton!
    
    //경로찾기시 거리표시 뷰 (call out)
    @IBOutlet weak var routeDistanceView: UIView!
    @IBOutlet weak var routeDistanceLabel: UILabel!
    @IBOutlet var routeDistanceBtn: UIView!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var tMapView: TMapView? = nil
    private var tMapPathData: TMapPathData = TMapPathData.init()
    private var routeStartPoint: TMapPoint? = nil
    private var routeEndPoint: TMapPoint? = nil
    private var resultTableView: PoiTableView?
    
    private var selectCharger: ChargerStationInfo? = nil
    private var stationInfoArr = [String:String]()
    
    private let dropDownWay = DropDown()
    private let dropDownPay = DropDown()
    private let dropDownRegion = DropDown()
    private let dropDownCompany = DropDown()
    
    private var filterWayIdArray = Array<Int>()
    private var filterPayIdArray = Array<Int>()

    private let regionList = Regions.init()
    
    static var currentLocation: TMapPoint? = nil
    var sharedChargerId: String? = nil
    
    private var loadedChargers = false
    private var clustering: ClusterManager? = nil
    private var currentClusterLv = 0
    private var isAllowedCluster = true
    private var isExistAddBtn = false
    var canIgnoreJejuPush = true
    
    private var summaryViewTag = 10
    private var summaryView:SummaryView!
    
    // 지킴이 점겸표 url
    private var checklistUrl: String?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        
        prepareRouteField()
        preparePOIResultView()
        prepareFilterView()
        prepareCheckBox()
        prepareMapView()
        prepareCalloutLayer()
        prepareNotificationCenter()
        prepareRouteView()
        prepareClustering()
        prepareMenuBtnLayer()
        
        prepareChargePrice()
        prepareSummaryView()
        requestStationInfo()
    }
    
//    override func viewWillLayoutSubviews() {
//        callOutLayer.addSubview(SummaryView(frame: callOutLayer.frame))
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        menuBadgeAdd()
        updateClustering()
        if self.sharedChargerId != nil {
            self.selectChargerFromShared()
        }
        canIgnoreJejuPush = UserDefault().readBool(key: UserDefault.Key.JEJU_PUSH)// default : false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Filter
    func prepareFilterView() {
        // drop down - init
        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = UIColor(rgb: 0x15435C)
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 15)
        DropDown.appearance().backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.85)
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 36
        
        let chargerFilter = ChargerFilter.init()
        // drop down - 도로
        dropDownWay.anchorView = self.btnWay
        dropDownWay.dataSource = chargerFilter.getWayFiltersName()
        dropDownWay.width = 100
        dropDownWay.direction = .bottom
        dropDownWay.bottomOffset = CGPoint(x: 0, y: (dropDownWay.anchorView?.plainView.bounds.height)!)
        dropDownWay.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnWay.setTitle(item, for: UIControlState.normal)
            // 설발행 위해 막음
//            self.defaults.saveInt(key: UserDefault.Key.FILTER_WAY, value: chargerFilter.getWayFiltersId()[index])
            self.drawTMapMarker()
        }
        // 설발행 위해 막음
//        setSelectionFromUserDefault(dropDown: dropDownWay, defaultKey: UserDefault.Key.FILTER_WAY, dic: ChargerFilter.WAY_FILTER_DIC, button: btnWay)
        
        // drop down - 과금
        dropDownPay.anchorView = self.btnPay
        dropDownPay.dataSource = chargerFilter.getPayFiltersName()
        dropDownPay.width = 100
        dropDownPay.direction = .bottom
        dropDownPay.bottomOffset = CGPoint(x: 0, y: (dropDownPay.anchorView?.plainView.bounds.height)!)
        dropDownPay.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnPay.setTitle(item, for: UIControlState.normal)
            // 설발행 위해 막음
//            self.defaults.saveInt(key: UserDefault.Key.FILTER_PAY, value: chargerFilter.getWayFiltersId()[index])
            self.drawTMapMarker()
        }
        // 설발행 위해 막음
//        setSelectionFromUserDefault(dropDown: dropDownPay, defaultKey: UserDefault.Key.FILTER_PAY, dic: ChargerFilter.PAY_FILTER_DIC, button: btnPay)
        
        // drop down - 지역
        dropDownRegion.anchorView = self.btnRegion
        dropDownRegion.dataSource = regionList.getNameList()
        dropDownRegion.width = 100
        dropDownRegion.direction = .bottom
        dropDownRegion.bottomOffset = CGPoint(x: 0, y: (dropDownRegion.anchorView?.plainView.bounds.height)!)
        dropDownRegion.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnRegion.setTitle(item, for: UIControlState.normal)
            self.myLocationModeOff()

            self.tMapView!.setZoomLevel(Int(self.regionList.getZoomLevel(index: index)))
            self.tMapView!.setCenter(self.regionList.getTmapPoint(index: index))
            self.drawTMapMarker()
        }
        
        // drop down - 기관
        let companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        var companyVisibilityList = ChargerManager.sharedInstance.getCompanyVisibilityList()
        
        dropDownCompany.anchorView = self.btnCompany
        self.btnCompany.setTitle("기관선택", for: UIControlState.normal)//(item, for: UIControlState.normal)
        dropDownCompany.dataSource = ChargerManager.sharedInstance.getCompanyNameList()
        dropDownCompany.width = 200
        dropDownCompany.direction = .bottom
        dropDownCompany.bottomOffset = CGPoint(x: 0, y: (dropDownCompany.anchorView?.plainView.bounds.height)!)
        dropDownCompany.dismissMode = .onTap
        dropDownCompany.selectionBackgroundColor = .clear
        dropDownCompany.cellNib = UINib(nibName: "DropDownCheckBoxCell", bundle: nil)
        
        dropDownCompany.customCellConfiguration = { (index: Int, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? DropDownCheckBoxCell else { return }
            cell.tag = index
            cell.setChecked(isChecked: companyVisibilityList[index])
        }
        
        dropDownCompany.multiSelectionAction = { [unowned self] (indexes, item) in
            self.dropDownCompany.clearSelection()
            
            let isAllSelected = companyVisibilityList[0]
            for (idx, _) in companyVisibilityList.enumerated() {
                companyVisibilityList[idx] = false
            }
            
            if (!isAllSelected && indexes.contains(0)) {
                for (idx, _) in companyVisibilityList.enumerated() {
                    self.dropDownCompany.selectRow(idx)
                    companyVisibilityList[idx] = true
                }
            } else if !(isAllSelected && !indexes.contains(0)) {
                for idx in indexes {
                    if idx > 0 {
                        self.dropDownCompany.selectRow(idx)
                        companyVisibilityList[idx] = true
                    }
                }
                if (isAllSelected && indexes.contains(0)) { // 전체선택이 되어있는 상태에서 일반 아이템이 빠지는 경우
                    companyVisibilityList[0] = false
                } else if (!isAllSelected && !indexes.contains(0)) {  // 전체선택이 안눌리고 그냥 일반 아이템만 에드할 경우
                    if (indexes.count == companyList.count) {
                        self.dropDownCompany.selectRow(0)
                        companyVisibilityList[0] = true
                    }
                }
            }
            
            for company in companyList {
                for (index, companyName) in self.dropDownCompany.dataSource.enumerated() {
                    if companyName == company.name {
                        if let companyId = company.company_id {
                            ChargerManager.sharedInstance.updateCompanyVisibility(isVisible: companyVisibilityList[index], companyID: companyId)
                            continue
                        }
                    }
                }
            }
            self.drawTMapMarker()
            self.dropDownCompany.reloadAllComponents()
        }
        
        let isSKR = MemberManager.isPartnershipClient(clientId: MemberManager.RENT_CLIENT_SKR);
        if isSKR {
            companyVisibilityList[0] = false
            dropDownCompany.deselectRow(0)
            for (index, _) in companyVisibilityList.enumerated(){
                if index == 1 || index == 2 {
                    dropDownCompany.selectRow(index)
                    companyVisibilityList[index] = true
                } else {
                    dropDownCompany.deselectRow(index)
                    companyVisibilityList[index] = false
                }
            }
            for company in companyList {
                for (index, companyName) in dropDownCompany.dataSource.enumerated() {
                    if companyName == company.name {
                        if let companyId = company.company_id {
                            ChargerManager.sharedInstance.updateCompanyVisibility(isVisible: companyVisibilityList[index], companyID: companyId)
                            continue
                        }
                    }
                }
            }
            drawTMapMarker()
            dropDownCompany.reloadAllComponents()
        } else {
            for (index, comVisible) in companyVisibilityList.enumerated(){
                if comVisible {
                    dropDownCompany.selectRow(index)
                } else {
                    dropDownCompany.deselectRow(index)
                    if companyVisibilityList[0] {
                        companyVisibilityList[0] = false
                        dropDownCompany.deselectRow(0)
                    }
                }
            }
        }
    }
    
    func setSelectionFromUserDefault(dropDown: DropDown, defaultKey: String, dic: [Int: String], button: UIButton) {
        if let ftString = dic[defaults.readInt(key: defaultKey)] {
            for (index, source) in dropDown.dataSource.enumerated() {
                if source.elementsEqual(ftString) {
                    dropDown.selectRow(index)
                    button.setTitle(source, for: UIControlState.normal)
                    self.drawTMapMarker()
                    break
                }
            }
        }
    }
    
    func prepareRouteView() {
        let findPath = UITapGestureRecognizer(target: self, action:  #selector (self.onClickShowNavi(_:)))
        self.routeDistanceBtn.addGestureRecognizer(findPath)
    }
    
    // checkbox - charger type
    func prepareCheckBox() {
        let checkBoxColor = UIColor(rgb: 0x15435C)
        
        cbDcCombo.boxType = .square
        cbDcCombo.checkState = getCheckState(key: UserDefault.Key.FILTER_DC_COMBO)
        cbDcCombo.tintColor = checkBoxColor
        cbDcCombo.tag = Const.CHARGER_TYPE_DCCOMBO
        svDcCombo.addTapGesture(target: self, action: #selector(onClickCbDcCombo(_:)))
        
        cbDcDemo.boxType = .square
        cbDcDemo.checkState = getCheckState(key: UserDefault.Key.FILTER_DC_DEMO)
        cbDcDemo.tintColor = checkBoxColor
        cbDcDemo.tag = Const.CHARGER_TYPE_DCDEMO
        svDcDemo.addTapGesture(target: self, action: #selector(onClickCbDcDemo(_:)))
        
        cbAc3.boxType = .square
        cbAc3.checkState = getCheckState(key: UserDefault.Key.FILTER_AC)
        cbAc3.tintColor = checkBoxColor
        cbAc3.tag = Const.CHARGER_TYPE_AC
        svAc3.addTapGesture(target: self, action: #selector(onClickCbAc3(_:)))
        
        cbSuper.boxType = .square
        cbSuper.checkState = getCheckState(key: UserDefault.Key.FILTER_SUPER_CHARGER)
        cbSuper.tintColor = checkBoxColor
        cbSuper.tag = Const.CHARGER_TYPE_SUPER_CHARGER
        svSuper.addTapGesture(target: self, action: #selector(onClickCbSuper(_:)))
        
        cbSlow.boxType = .square
        cbSlow.checkState = getCheckState(key: UserDefault.Key.FILTER_SLOW)
        cbSlow.tintColor = checkBoxColor
        cbSlow.tag = Const.CHARGER_TYPE_SLOW
        svSlow.addTapGesture(target: self, action: #selector(onClickCbSlow(_:)))
    }
    
    func prepareMapView() {
        tMapView = TMapView.init(frame: mapContainerView.frame.bounds)
        guard let mapView = tMapView else {
            print("[Main] TMap 생성을 실패했습니다")
            return
        }
        
        mapView.setSKTMapApiKey(Const.TMAP_APP_KEY)
        
        // Load Last Zoom Level
        if defaults.readInt(key: UserDefault.Key.MAP_ZOOM_LEVEL) > 0 {
            mapView.setZoomLevel(defaults.readInt(key: UserDefault.Key.MAP_ZOOM_LEVEL))
        } else {
            mapView.setZoomLevel(15)
        }
        if defaults.readInt(key: UserDefault.Key.SETTINGS_CLUSTER_ZOOMLEVEL) < 1 {
            defaults.registerBool(key: UserDefault.Key.SETTINGS_CLUSTER, val: false)
            defaults.registerInt(key: UserDefault.Key.SETTINGS_CLUSTER_ZOOMLEVEL, val: 11)
        }
        
        mapView.delegate = self
        mapView.gpsManagersDelegate = self
        mapView.setTrackingMode(true)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapContainerView.addSubview(mapView)
        
        // Map Refresh an myLocation Button Look change
        myLocationButton.layer.cornerRadius = 5
        myLocationButton.clipsToBounds = true
        myLocationButton.layer.shadowRadius = 5
        myLocationButton.layer.shadowColor = UIColor.black.cgColor
        myLocationButton.layer.shadowOpacity = 0.5
        myLocationButton.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        myLocationButton.layer.masksToBounds = false
        updateMyLocationButton()
        
        reNewButton.layer.cornerRadius = 5
        reNewButton.clipsToBounds = true
        reNewButton.layer.shadowRadius = 5
        reNewButton.layer.shadowColor = UIColor.black.cgColor
        reNewButton.layer.shadowOpacity = 0.5
        reNewButton.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        reNewButton.layer.masksToBounds = false

        btn_menu_layer.layer.cornerRadius = 5
        btn_menu_layer.clipsToBounds = true
        btn_menu_layer.layer.shadowRadius = 5
        btn_menu_layer.layer.shadowColor = UIColor.gray.cgColor
        btn_menu_layer.layer.shadowOpacity = 0.5
        btn_menu_layer.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        btn_menu_layer.layer.masksToBounds = false
    }
    
    // btnChargePrice radius, color, shadow
    func prepareChargePrice() {
        btnChargePrice.layer.cornerRadius = 16
        btnChargePrice.layer.shadowRadius = 5
        btnChargePrice.layer.shadowColor = UIColor.black.cgColor
        btnChargePrice.layer.shadowOpacity = 0.3
        btnChargePrice.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        btnChargePrice.layer.masksToBounds = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onClickChargePrice))
        btnChargePrice.addGestureRecognizer(gesture)
    }
    
    func prepareSummaryView() {
        
    }
    
    func handleError(error: Error?) -> Void {
        if let error = error as NSError? {
            print(error)
            let alert = UIAlertController(title: self.title!, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setStartPoint() {
       if self.selectCharger != nil {
           guard let tc = toolbarController else {
               return
           }
           let appTc = tc as! AppToolbarController
           appTc.enableRouteMode(isRoute: true)
           
           startField.text = selectCharger?.mStationInfoDto?.mSnm
        
           routeStartPoint = selectCharger?.getTMapPoint()
       }
    }
    
    func setEndPoint() {
        if self.selectCharger != nil {
            guard let tc = toolbarController else {
                return
            }
            let appTc = tc as! AppToolbarController
            appTc.enableRouteMode(isRoute: true)
            
            endField.text = selectCharger?.mStationInfoDto?.mSnm
            routeEndPoint = selectCharger?.getTMapPoint()
        }
    }
    
    func setStartPath() {
        if self.selectCharger != nil {
            let passList = [selectCharger?.getTMapPoint()]
            findPath(passList: passList as! [TMapPoint])
        }
    }
    
    @objc func onClickChargePrice(sender: UITapGestureRecognizer) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let priceInfoVC: TermsViewController = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        priceInfoVC.tabIndex = .PriceInfo
        self.navigationController?.push(viewController: priceInfoVC)
    }
    
    // MARK: - Action for button
    @IBAction func onClickMyLocation(_ sender: UIButton) {
        if let mapView = tMapView {
            if isLocationEnabled(){
                if mapView.getIsTracking() {
                    tMapView?.setCompassMode(true)
                } else {
                    tMapView?.setTrackingMode(true)
                }
                updateMyLocationButton()
            } else {
                askPermission()
            }
        }
    }
    
    @IBAction func onClickRenewBtn(_ sender: UIButton) {
        if !self.markerIndicator.isAnimating {
            self.refreshChargerInfo()
        }
    }
    
    @IBAction func onClickRouteStartPoint(_ sender: UIButton) {
        self.setStartPoint()
    }
    
    @IBAction func onClickRouteEndPoint(_ sender: UIButton) {
        self.setEndPoint()
    }
    
    @IBAction func onClickShowNavi(_ sender: Any) {
        var snm = endField.text ?? ""
        var lng = routeEndPoint?.getLongitude() ?? 0.0
        var lat = routeEndPoint?.getLatitude() ?? 0.0
        if snm.isEmpty, lng == 0.0, lat == 0.0 {
            snm = selectCharger?.mStationInfoDto?.mSnm ?? ""
            lng = selectCharger?.mStationInfoDto?.mLongitude ?? 0.0
            lat = selectCharger?.mStationInfoDto?.mLatitude ?? 0.0
        }
        UtilNavigation().showNavigation(vc: self, snm: snm, lat: lat, lng: lng)
    }
    
    @IBAction func onClickRouteAddPoint(_ sender: UIButton) {
        if selectCharger != nil {
            let passList = [selectCharger?.getTMapPoint()]
            findPath(passList: passList as! [TMapPoint])
        }
    }
    
    @IBAction func onClickWayButton(_ sender: UIButton) {
        self.dropDownWay.show()
    }
    
    @IBAction func onClickPayButton(_ sender: UIButton) {
        self.dropDownPay.show()
    }
    
    @IBAction func onClickRegionButton(_ sender: UIButton) {
        self.dropDownRegion.show()
    }
    
    @IBAction func onClickCompanyButton(_ sender: UIButton) {
        self.dropDownCompany.show()
    }
    
    // checkbox click한 경우
    @IBAction func onClickCb(_ sender: M13Checkbox) {
        self.saveFilterState()
        self.drawTMapMarker()
    }
    
    // checkbox label click한 경우
    @IBAction func onClickCbDcCombo(_ sender: UITapGestureRecognizer) {
        self.cbDcCombo.toggleCheckState(true)
        self.saveFilterState()
        self.drawTMapMarker()
    }
    
    @IBAction func onClickCbDcDemo(_ sender: UITapGestureRecognizer) {
        self.cbDcDemo.toggleCheckState(true)
        self.saveFilterState()
        self.drawTMapMarker()
    }
    
    @IBAction func onClickCbAc3(_ sender: UITapGestureRecognizer) {
        self.cbAc3.toggleCheckState(true)
        self.saveFilterState()
        self.drawTMapMarker()
    }
    
    @IBAction func onClickCbSuper(_ sender: UITapGestureRecognizer) {
        self.cbSuper.toggleCheckState(true)
        self.saveFilterState()
        self.drawTMapMarker()
    }
    
    @IBAction func onClickCbSlow(_ sender: UITapGestureRecognizer) {
        self.cbSlow.toggleCheckState(true)
        self.saveFilterState()
        self.drawTMapMarker()
    }
}

extension MainViewController {
    internal func drawTMapMarker() {
        if !ChargerManager.sharedInstance.isReady() { return }

        self.clustering?.clustering(filter: self.getCurrentFilter(), loadedCharger: self.loadedChargers)
        
        if !self.loadedChargers {
            self.loadedChargers = true
            if self.sharedChargerId != nil {
                self.selectChargerFromShared()
            }
        }
    }
    
    internal func isContainMap(point: TMapPoint) -> Bool {
        var isContain = false;
        if (tMapView!.getRightBottomPoint().getLatitude() <= point.getLatitude()
            && point.getLatitude() <= tMapView!.getLeftTopPoint().getLatitude()
            && point.getLongitude() <= tMapView!.getRightBottomPoint().getLongitude()
            && tMapView!.getLeftTopPoint().getLongitude() <= point.getLongitude()) {
            isContain = true;
        }
        return isContain
    }
    
    internal func saveFilterState() {
        self.defaults.saveString(key: UserDefault.Key.FILTER_DC_COMBO, value: cbDcCombo.checkState.rawValue)
        self.defaults.saveString(key: UserDefault.Key.FILTER_DC_DEMO, value: cbDcDemo.checkState.rawValue)
        self.defaults.saveString(key: UserDefault.Key.FILTER_AC, value: cbAc3.checkState.rawValue)
        self.defaults.saveString(key: UserDefault.Key.FILTER_SUPER_CHARGER, value: cbSuper.checkState.rawValue)
        self.defaults.saveString(key: UserDefault.Key.FILTER_SLOW, value: cbSlow.checkState.rawValue)
    }
    
    internal func getCheckState(key: String) -> M13Checkbox.CheckState {
        var checkState = defaults.readString(key: key)
        if checkState.isEmpty {
            checkState = "Checked"
        }
        return M13Checkbox.CheckState(rawValue: checkState) ?? .checked
    }
    
    internal func checkFilterForCarType() {
        let carType = UserDefault().readInt(key: UserDefault.Key.MB_CAR_TYPE);
        if carType != 8 {
            cbDcDemo.checkState = .unchecked
            cbAc3.checkState = .unchecked
            cbDcCombo.checkState = .unchecked
            cbSuper.checkState = .unchecked
            cbSlow.checkState = .unchecked
            
            switch(carType) {
            case Const.CHARGER_TYPE_DCDEMO:
                cbDcDemo.checkState = .checked
                
            case Const.CHARGER_TYPE_DCCOMBO:
                cbDcCombo.checkState = .checked
                
            case Const.CHARGER_TYPE_AC:
                cbAc3.checkState = .checked
                
            case Const.CHARGER_TYPE_SUPER_CHARGER:
                cbSuper.checkState = .checked
                
            case Const.CHARGER_TYPE_SLOW:
                cbSlow.checkState = .checked
                
            default:
                break
            }
            self.saveFilterState()
        }
    }
    
    internal func getCurrentFilter() -> ChargerFilter {
        let filter = ChargerFilter.init()
        filter.dcDemo = (cbDcDemo.checkState == .checked)
        filter.ac3 = (cbAc3.checkState == .checked)
        filter.dcCombo = (cbDcCombo.checkState == .checked)
        filter.superCharger = (cbSuper.checkState == .checked)
        filter.slow = (cbSlow.checkState == .checked)
        
        if let index = dropDownWay.indexForSelectedRow {
            filter.wayId = filter.getWayFiltersId()[index]
        }
        if let index = dropDownPay.indexForSelectedRow {
            filter.payId = filter.getPayFiltersId()[index]
        }
        
//        let companyName = dropDownCompany.selectedItem
        let companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        for company in companyList {
            if let companyId = company.company_id {
                filter.companies.updateValue(company.is_visible, forKey: companyId)
            }
        }
        return filter
    }
}

// MARK: - Delegate
extension MainViewController: AppToolbarDelegate {
    func toolBar(didClick iconButton: IconButton, arg: Any?) {
        switch iconButton.tag {
        case 1: // 충전소 검색 버튼
            let mapStoryboard = UIStoryboard(name : "Map", bundle: nil)
            let searchVC:SearchViewController = mapStoryboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            searchVC.delegate = self
            self.present(AppSearchBarController(rootViewController: searchVC), animated: true, completion: nil)
            
        case 2: // 경로 찾기 버튼
            if let isRouteMode = arg {
                showRouteView(isShow: isRouteMode as! Bool)
            }
            
        default:
            break
        }
    }
    
    func showRouteView(isShow: Bool) {
        if isShow {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                self.filterView.transform = CGAffineTransform( translationX: 0.0, y: self.routeView.bounds.height )
                self.myLocationButton.transform = CGAffineTransform( translationX: 0.0, y: self.routeView.bounds.height )
                self.reNewButton.transform = CGAffineTransform( translationX: 0.0, y: self.routeView.bounds.height )
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                self.filterView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                self.myLocationButton.transform = CGAffineTransform( translationX: 0.0, y: 0.0)
                self.reNewButton.transform = CGAffineTransform( translationX: 0.0, y: 0.0)
            }, completion: nil)
            clearSearchResult()
        }
    }
}

extension MainViewController: TextFieldDelegate {
    func prepareRouteField() {
        startField.tag = ROUTE_START
        startField.delegate = self
        if startField.placeholder == nil {
            startField.placeholder = "출발지를 입력하세요"
        }
        startField.placeholderAnimation = .hidden
        startField.isClearIconButtonEnabled = true
        startField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        endField.tag = ROUTE_END
        endField.delegate = self
        endField.placeholder = "도착지를 입력하세요"
        endField.placeholderAnimation = .hidden
        endField.isClearIconButtonEnabled = true
        endField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        btnRouteCancel.addTarget(self, action: #selector(onClickRouteCancel(_:)), for: .touchUpInside)
        btnRoute.addTarget(self, action: #selector(onClickRoute(_:)), for: .touchUpInside)

        routeDistanceView.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            hideResultView()
        } else {
            showResultView()
            
            let word = textField.text
            DispatchQueue.global(qos: .background).async {
                if let poiList = self.tMapPathData.requestFindAllPOI(word) {
                    if poiList.count > 0 {
                        DispatchQueue.main.async {
                            self.resultTableView?.setPOI(list: poiList as! [TMapPOIItem])
                            self.resultTableView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func onClickRouteCancel(_ sender: UIButton) {
        clearSearchResult()
    }
    
    @objc func onClickRoute(_ sender: UIButton) {
        findPath(passList: [])
    }
    
    func clearSearchResult() {
//        if self.isExistAddBtn {   // 경유지버튼 있을경우
//            self.addPointBtn.isHidden = true    // 경유지버튼 숨김
//            self.naviBtn.isHidden = false   // 길안내버튼 추가
//        }
        self.isExistAddBtn = false
        
        hideKeyboard()
        hideResultView()
        
        setView(view: routeDistanceView, hidden: true)
        self.btnChargePrice.isHidden = false
        self.btn_menu_layer.isHidden = false
        
        startField.text = ""
        endField.text = ""
        
        routeStartPoint = nil
        routeEndPoint = nil

        btnRouteCancel.setTitle("지우기", for: .normal)
        
        tMapView?.removeTMapPath()
        tMapView?.removeCustomObject("start")
        tMapView?.removeCustomObject("end")
        
        // 경로 주변 충전소 초기화
        for charger in ChargerManager.sharedInstance.getChargerStationInfoList(){
            charger.isAroundPath = true
        }
        
        self.clustering?.isRouteMode = false;

        drawTMapMarker()
    }
    
    func findPath(passList: [TMapPoint]) {
        if routeStartPoint == nil{
            
            selectCharger?.mStationInfoDto?.mLongitude = routeEndPoint?.getLongitude()
            selectCharger?.mStationInfoDto?.mLongitude = routeEndPoint?.getLatitude()
            
            
            if let currentPoint = MainViewController.currentLocation {
                startField.text = tMapPathData.convertGpsToAddress(at: currentPoint)
                routeStartPoint = currentPoint
                selectCharger?.mStationInfoDto?.mSnm = endField.text
            }
            selectCharger?.mStationInfoDto?.mSnm = endField.text
        }
        
        if let startPoint = routeStartPoint, let endPoint = routeEndPoint {
            markerIndicator.startAnimating()
            
            // 키보드 숨기기
            hideKeyboard()
            
            // 검색 결과창 숨기기
            hideResultView()
            
            // 하단 충전소 정보 숨기기
            setView(view: callOutLayer, hidden: true)
            
            self.btnChargePrice.isHidden = true
            self.btn_menu_layer.isHidden = true
            
            // 출발, 도착이 모두 나오도록 zoom level 변경
            var latSpan = startPoint.getLatitude() - endPoint.getLatitude()
            latSpan = abs(latSpan * 2.0)
            var lonSpan = startPoint.getLongitude() - endPoint.getLongitude()
            lonSpan = abs(lonSpan * 2.0)
            self.tMapView?.zoom(toLatSpan: latSpan, lonSpan: lonSpan)
            
            // 출발, 도착의 가운데 지점으로 map 이동
            let centerLat = abs((startPoint.getLatitude() + endPoint.getLatitude()) / 2)
            let centerLon = abs((startPoint.getLongitude() + endPoint.getLongitude()) / 2)
            self.tMapView?.setCenter(TMapPoint.init(lon: centerLon, lat: centerLat))
            
            // 경유지 추가 버튼 활성화
//            btnRouteCancel.setTitle("경로취소", for: .normal)
//            if !self.isExistAddBtn { // 경유지버튼 없을경우
//                self.naviBtn.isHidden = true    // 길안내버튼 숨김
//                self.addPointBtn.isHidden = false   // 경유지버튼 추가
//            }
            self.isExistAddBtn = true
            
            // 경로 요청
            DispatchQueue.global(qos: .background).async {
                var polyLine: TMapPolyLine
                if passList.count > 0 { // 경유지 추가
                    polyLine = self.tMapPathData.findMultiPathData(withStart: startPoint, end: endPoint, passPoints: passList, searchOption: 0)
                } else {
                    if startPoint.getLatitude() == endPoint.getLatitude() &&
                        startPoint.getLongitude() == endPoint.getLongitude() { // 출발, 도착지가 같은 경우
                        polyLine = TMapPolyLine.init()
                        polyLine.addPoint(TMapPoint.init(lon: startPoint.getLongitude(), lat: startPoint.getLatitude()))
                    } else {
                        polyLine = self.tMapPathData.find(from: startPoint, to: endPoint)
                    }
                }
                
                DispatchQueue.main.async {
                    // 지도에 경로 그리기
                    self.drawPathData(polyLine: polyLine);
                    self.markerIndicator.stopAnimating()
                }
            }
        }
    }
    
    func drawPathData(polyLine: TMapPolyLine) {
        tMapView?.addTMapPath(polyLine)
        
        // 경로 주변 충전소만 표시
        findChargerAroundRoute(polyLine: polyLine);
        self.clustering?.isRouteMode = true

        drawTMapMarker()
        
        // 두 지점간 거리 표시
        let distance = round(polyLine.getDistance())
        var strDistance:NSString
        if distance > 1000 {
            strDistance = NSString(format: "%dKm", Int(distance/1000))
        } else {
            strDistance = NSString(format: "%dm", Int(distance))
        }
        routeDistanceLabel.text = strDistance as String
        
        setView(view: routeDistanceView, hidden: false)
    }
    
    func findChargerAroundRoute(polyLine: TMapPolyLine) {
        for charger in ChargerManager.sharedInstance.getChargerStationInfoList(){
            charger.isAroundPath = false
        }
        
        if let tMapPointArray = polyLine.getPoint() {
            for i in stride(from: 0, to: tMapPointArray.count, by: 100) {
                let tMapPoint = tMapPointArray[i] as! TMapPoint;
                for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
                    if (!charger.isAroundPath) {
                        let chargerPoint = charger.getTMapPoint()
                        let distance = tMapPoint.getDistanceWith(chargerPoint)
                        if (distance < 5000.0) {  // 5km 이내 충전소
                            charger.isAroundPath = true;
                        }
                    }
                }
            }
        }
    }
    
    func hideKeyboard() {
        startField.endEditing(true)
        endField.endEditing(true)
    }
    
    func hideResultView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {() -> Void in
            self.resultTableView?.transform = CGAffineTransform( translationX: 0.0, y: (self.resultTableView?.frame.height)! )
        }, completion: nil)
    }
    
    func showResultView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
            self.resultTableView?.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
        }, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // text filed가 선택되었을 때 result view의 종류(start, end) 설정
        resultTableView?.tag = textField.tag
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        hideResultView()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        return true
    }
}

extension MainViewController: PoiTableViewDelegate {
    func preparePOIResultView() {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let frame = CGRect(x: 0, y: filterView.frame.height, width: screenWidth, height: screenHeight - filterView.frame.height)
        
        resultTableView = PoiTableView.init(frame: frame, style: .plain)
        resultTableView?.poiTableDelegate = self
        view.addSubview(resultTableView!)
        hideResultView()
    }
    
    func didSelectRow(poiItem: TMapPOIItem) {
        // 선택한 주소로 지도 이동
        self.tMapView?.setCenter(poiItem.getPOIPoint())
        hideResultView()
        
        // 출발지, 도착지 설정
        if resultTableView?.tag == ROUTE_START {
            startField.text = poiItem.name
            routeStartPoint = poiItem.getPOIPoint()
            
            poiItem.setIcon(UIImage(named: "marker_route_start"), anchorPoint: CGPoint(x: 0.5, y: 1.0))
            tMapView?.removeCustomObject("start")
            tMapView?.addCustomObject(poiItem, id: "start")
        } else {
            endField.text = poiItem.name
            routeEndPoint = poiItem.getPOIPoint()
            
            poiItem.setIcon(UIImage(named: "marker_route_end"), anchorPoint: CGPoint(x: 0.5, y: 1.0))
            tMapView?.removeCustomObject("end")
            tMapView?.addCustomObject(poiItem, id: "end")
        }
    }
}

extension MainViewController: TMapGpsManagerDelegate {
    func locationChanged(_ newTmp: TMapPoint!) {
        MainViewController.currentLocation = newTmp
        if !(canIgnoreJejuPush) {
            checkJeJuBoundary()
        }
    }
    
    func headingChanged(_ heading: Double) {
        
    }
}

extension MainViewController: TMapViewDelegate {
    func onClick(_ TMP: TMapPoint!) {
        hideKeyboard()
        myLocationModeOff()
        setView(view: callOutLayer, hidden: true)
        if selectCharger != nil {
            if let markerItem = tMapView!.getMarketItem(fromID: selectCharger!.mChargerId) {
                markerItem.setIcon(selectCharger!.getMarkerIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
            }
            selectCharger = nil
        }
    }
    
    func onCustomObjectClick(_ obj: TMapObject!) {
        hideKeyboard()
        let markerItem = obj as! TMapMarkerItem
        if markerItem.getID()!.contains("cluster") {
            if markerItem.getID()!.contains("cluster4") {
                self.tMapView?.setZoomLevel(ClusterManager.LEVEL_3_ZOOM)
            } else if markerItem.getID()!.contains("cluster3") {
                self.tMapView?.setZoomLevel(ClusterManager.LEVEL_2_ZOOM)
            } else {
                    self.tMapView?.setZoomLevel(ClusterManager.LEVEL_1_ZOOM)
            }
            self.tMapView?.setCenter(markerItem.getTMapPoint())
        } else {
            selectCharger(chargerId: markerItem.getID());
        }
    }
    
    func onDidEndScroll(withZoomLevel zoomLevel: Int, center mapPoint: TMapPoint!) {
        updateMyLocationButton()
        self.drawTMapMarker()
    }
}

extension MainViewController: ChargerSelectDelegate {
    func moveToSelectLocation(lat: Double, lon: Double) {
        if lat != 0 && lon != 0 {
            myLocationModeOff()
            self.tMapView?.setZoomLevel(15)
            self.tMapView?.setCenter(TMapPoint.init(lon: lon, lat: lat))
        }
    }
    
    func moveToSelected(chargerId: String) {
        if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId){
            self.tMapView?.setZoomLevel(15)
            self.tMapView?.setCenter(charger.getTMapPoint())
            
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                DispatchQueue.main.async {
                    self.selectCharger(chargerId: chargerId)
                }
            }
        }
    }
}

// MARK: - Callout
extension MainViewController: MainViewDelegate {
    
    func prepareCalloutLayer() {
        callOutLayer.isHidden = true
        addCalloutClickListener()
    }
    
    func redrawCalloutLayer() {
        if let charger = selectCharger {
            showCallOut(charger: charger)
        }
    }
    
    func addCalloutClickListener() {
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onClickCalloutLayer (_:)))
        self.callOutLayer.addGestureRecognizer(gesture)
    }
    
    @objc func onClickCalloutLayer(_ sender:UITapGestureRecognizer) {
        print("csj", "onClickCalloutLayer")
        let detailStoryboard = UIStoryboard(name : "Detail", bundle: nil)
        let detailVC:DetailViewController = detailStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.mainViewDelegate = self
        detailVC.charger = self.selectCharger
        detailVC.stationInfoArr = self.stationInfoArr
        detailVC.checklistUrl = self.checklistUrl
        detailVC.isExistAddBtn = self.isExistAddBtn
        
        self.navigationController?.push(viewController: detailVC, subtype: kCATransitionFromTop)
    }
    
    func selectCharger(chargerId: String) {
        if summaryView == nil {
            summaryView = SummaryView(frame: callOutLayer.frame.bounds)
        }
        summaryView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        callOutLayer.addSubview(summaryView)
        
//        if let summary = summaryView {
//            summaryView = SummaryView(frame: callOutLayer.frame.bounds)
//        }
        
        
        
//        let frame:CGRect = callOutLayer.bounds
//        self.summaryView = SummaryView(frame: frame)
//
//        if let summary = summaryView {
//            summary.tag = self.summaryViewTag
//            view.addSubview(summary)
            
//            summary.translatesAutoresizingMaskIntoConstraints = false
//            view.addConstraint(NSLayoutConstraint(item: summary, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
//            view.addConstraint(NSLayoutConstraint(item: summary, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
//            view.addConstraint(NSLayoutConstraint(item: summary, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
            
//            print("csj_", "summary != nil")
//        }else{
//            print("csj_", "summary == nil")
//        }
        
//        view.addConstraint(NSLayoutConstraint(item: summaryView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
//        view.addConstraint(NSLayoutConstraint(item: summaryView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
//        view.addConstraint(NSLayoutConstraint(item: summaryView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))

        
        myLocationModeOff()
        
        // 이전에 선택된 충전소 마커를 원래 마커로 원복
        if selectCharger != nil {
            if let markerItem = tMapView!.getMarketItem(fromID: selectCharger!.mChargerId) {
                markerItem.setIcon(selectCharger!.getMarkerIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
                
            }
            selectCharger = nil
        }
        
        // 선택한 충전소 정보 표시
        if let selectCharger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
            showCallOut(charger: selectCharger)
        } else {
            print("Not Found Charger \(ChargerManager.sharedInstance.getChargerStationInfoList().count)")
        }
    }
    
    func showCallOut(charger: ChargerStationInfo) {
        selectCharger = charger
        if let totalType = selectCharger?.mTotalType {
//            setChargerTypeImage(type: totalType)
//            setChargerPower()
        }
        
        if let pay = selectCharger?.mStationInfoDto?.mPay {
//            setChargePrice(pay: pay)
        }
        
//        setCallOutFavoriteIcon(charger: selectCharger!)
//
//        setDistance()
       
//        callOutStatusBar.backgroundColor = selectCharger?.cidInfo.getCstColor(cs
        
//        setCallOutLb()
        
//        let chargeState = callOutStatus.text
//        stationInfoArr[chargeState ?? ""] = "chargeState"
//
//        self.markerImg.image = selectCharger?.getChargeStateImg(type: chargeState!)
//
        setView(view: callOutLayer, hidden: false)

        if let markerItem = self.tMapView!.getMarketItem(fromID: self.selectCharger!.mChargerId) {
            if (markerItem.getIcon().isEqual(other: self.selectCharger!.getSelectIcon())) == false {
                markerItem.setIcon(self.selectCharger!.getSelectIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
            }
        }
    }
    
//    func setCallOutLb() {
//        callOutTitle.text = selectCharger?.mStationInfoDto?.mSnm
//
//        callOutStatus.text = selectCharger?.cidInfo.cstToString(cst: selectCharger?.mTotalStatus ?? 2)
//
//        if selectCharger?.getCompanyIcon() != nil {
//            self.companyImg.image = selectCharger?.getCompanyIcon()
//        } else {
//            self.companyImg.image = .none
//        }
//    }
//
//    func setCallOutFavoriteIcon(charger: ChargerStationInfo) {
//        if charger.mFavorite {
//            callOutFavorite.setImage(UIImage(named: "bookmark_on"), for: .normal)
//        } else {
//            callOutFavorite.setImage(UIImage(named: "bookmark"), for: .normal)
//        }
//    }
//
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
//
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
//
//    func setChargerTypeImage(type:Int) {
//        // "DC차데모"
//        if (type & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
//            self.typeDemoLb.isHidden = false
//        } else {
//            self.typeDemoLb.isHidden = true
//        }
//
//        // "DC콤보"
//        if (type & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
//            self.typeComboLb.isHidden = false
//        } else {
//            self.typeComboLb.isHidden = true
//        }
//
//        // "AC3상"
//        if (type & Const.CTYPE_AC) == Const.CTYPE_AC {
//            self.typeACLb.isHidden = false
//        } else {
//            self.typeACLb.isHidden = true
//        }
//
//        // "완속"
//        if (type & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
//            self.typeSlowLb.isHidden = false
//        } else {
//            self.typeSlowLb.isHidden = true
//        }
//
//        // "슈퍼차저"
//        if (type & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
//            self.typeSuperLb.isHidden = false
//        } else {
//            self.typeSuperLb.isHidden = true
//        }
//
//        // "데스티네이션"
//        if (type & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
//            self.typeDestiLb.isHidden = false
//        } else {
//            self.typeDestiLb.isHidden = true
//        }
//
//        DispatchQueue.main.async {
//            self.distanceLb.text = "test"
//        }
//    }
//
//    func setChargerPower() {
//        let power = selectCharger?.getChargerPower(power: (selectCharger?.mPower)!, type: (selectCharger?.mTotalType)!)
//        self.chargePowerLb.text = power
//        stationInfoArr[power ?? ""] = "power"
//    }
//
//    // -> chargerStationInfo class로
////    chargerStationInfo -> getChargerPower
////    self.chargePowerLb.text = strPower
////    stationInfoArr[strPower] = "power"
//
////    chargerStationInfo -> getChargeStateImg
////    self.markerImg.clipsToBounds = true
//
//    func setChargePrice(pay: String) {
//        // 과금
//        switch pay {
//        case "Y":
//            self.chargePriceLb.text = "유료"
//            stationInfoArr["유료"] = "pay"
//        case "N":
//            self.chargePriceLb.text = "무료"
//            stationInfoArr["무료"] = "pay"
//        default:
//            self.chargePriceLb.text = "시범운영"
//            stationInfoArr["시범운영"] = "pay"
//        }
//    }
}

// MARK: - Request To Server
extension MainViewController {
    /*
    internal func getChargerInfo() {
        Server.getStationList { (isSuccess, responseData) in
            if isSuccess {
                if let data = responseData {
                    let chargerData = try! JSONDecoder().decode(DecChargerList.self, from: data)
                    for item in chargerData.list {
                        if ((self.chargerManager.chargerDict[item.chargerId]) == nil) {
                            self.chargerManager.chargerDict[item.chargerId] = item
                        }
                    }
                }
                
                self.chargerManager.chargerList = [Charger](self.chargerManager.chargerDict.values)
                self.markerIndicator.startAnimating()
                self.drawTMapMarker()
                self.markerIndicator.stopAnimating()
                
                // app 실행 시 전면 광고 dialog
                self.showStartAd()
                
                self.checkFCM()
                
                // 즐겨찾기 목록 가져오기
                self.chargerManager.getFavoriteCharger()
                
                // 지킴이 충전소 목록 요청
                self.getChargerListForGuard()
            } else {
                self.checkFCM()
            }
            
            if Const.CLOSED_BETA_TEST {
                CBT.checkCBT(vc: self)
            }
        }
    }
    */
    func requestStationInfo() {
        ChargerManager.sharedInstance.getStationInfoFromServer(listener: {

            class chargerManagerListener: ChargerManagerListener {
                func onComplete() {
                    controller?.markerIndicator.startAnimating()
                    controller?.drawTMapMarker()
                    controller?.markerIndicator.stopAnimating()
                    
                    // app 실행 시 전면 광고 dialog
                    controller?.showStartAd()
                    
                    controller?.checkFCM()
                    
                    // 즐겨찾기 목록 가져오기
                    ChargerManager.sharedInstance.getFavoriteCharger()
                    
                    // 지킴이 충전소 목록 요청
                    controller?.getChargerListForGuard()
                    
                    if Const.CLOSED_BETA_TEST {
                        CBT.checkCBT(vc: controller!)
                    }
                    controller?.getIntroImage()
                }
                
                func onError(errorMsg: String) {
                    controller?.checkFCM()
                    
                    if Const.CLOSED_BETA_TEST {
                        CBT.checkCBT(vc: controller!)
                    }
                }
                
                var controller: MainViewController?
                required init(_ controller : MainViewController) {
                    self.controller = controller
                }
            }
            return chargerManagerListener(self)
        }())
    }
    
    internal func getChargerListForGuard() {
        if MemberManager().isGuard() {
            Server.getStationListForGuard { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    let list = json["list"]
                    for (_, id):(String, JSON) in list {
                        if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: id.stringValue){
                            charger.mGuard = true
                        }
                    }
                }
            }
            Server.getChecklistLink { (isSuccess, value) in
                if isSuccess {
                    let json = JSON(value)
                    self.checklistUrl = json["url"].stringValue
                }
            }
        }
    }
    
    internal func refreshChargerInfo() {
        self.markerIndicator.startAnimating()

        Server.getStationStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let list = json["list"]
                
                for (_, item):(String, JSON) in list {
                    let id = item["id"].stringValue
                    if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: id){
                        charger.changeStatus(status: item["st"].intValue)
                        
                        if (self.tMapView!.getMarketItem(fromID: charger.mChargerId) != nil) {
                            if self.tMapView!.getMarketItem(fromID: id).getIcon() != charger.marker.getIcon() {
                                self.tMapView!.getMarketItem(fromID: id).setIcon(charger.marker.getIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
                            }
                        }
                    }
                }
            }
            self.markerIndicator.stopAnimating()
        }
    }
    
    private func checkJeJuBoundary() {
        if let point = MainViewController.currentLocation {
            if 33.11 <= point.getLatitude() && point.getLatitude() <= 33.969
            && 126.13 <= point.getLongitude() && point.getLongitude() <= 126.99 {
                canIgnoreJejuPush = true
                let window = UIApplication.shared.keyWindow!
                window.addSubview(PopUpDialog(frame: window.bounds))
            }
        }
    }
    
    private func getIntroImage(){
        Server.getIntroImage { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let checker = IntroImageChecker.init()
                checker.checkIntroImage(response: json)
            }
        }
    }
}

extension MainViewController {
    func prepareNotificationCenter() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(saveLastZoomLevel), name: .UIApplicationDidEnterBackground, object: nil)
        center.addObserver(self, selector: #selector(updateMemberInfo), name: Notification.Name("updateMemberInfo"), object: nil)
        center.addObserver(self, selector: #selector(getSharedChargerId(_:)), name: Notification.Name("kakaoScheme"), object: nil)
        center.addObserver(self, selector: #selector(openPartnership(_:)), name: Notification.Name("partnershipScheme"), object: nil)
    }
    
    func removeObserver() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name("updateMemberInfo"), object: nil)
    }
    
    @objc func saveLastZoomLevel() {
        if let tmapview = self.tMapView {
            UserDefault().saveInt(key: UserDefault.Key.MAP_ZOOM_LEVEL, value: tmapview.getZoomLevel())
        }
    }
    
    @objc func updateMemberInfo() {
        checkFilterForCarType()
    }
    
    @objc func getSharedChargerId(_ notification: NSNotification) {
        let sharedid = notification.userInfo?["sharedid"] as! String
        self.sharedChargerId = sharedid
        if self.loadedChargers {
            selectChargerFromShared()
        }
    }
    
    @objc func openPartnership(_ notification: NSNotification) {
        if MemberManager().isLogin() {
            let mbsStoryboard = UIStoryboard(name : "Membership", bundle: nil)
            let mbscdVC = mbsStoryboard.instantiateViewController(withIdentifier: "MembershipCardViewController") as! MembershipCardViewController
            navigationController?.push(viewController: mbscdVC)
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    func selectChargerFromShared() {
        if let id = self.sharedChargerId {
            self.selectCharger(chargerId: id)
            self.sharedChargerId = nil
            if let sharedCharger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: id) {
                self.tMapView?.setCenter(sharedCharger.getTMapPoint())
            }
        }
    }

    func isLocationEnabled() ->Bool{
        var enabled : Bool = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    enabled = true
                    break
                case .notDetermined, .restricted, .denied:
                    break
            }
        }
        return enabled
    }
    
    func askPermission(){
        let alertController = UIAlertController(title: "위치정보가 활성화되지 않았습니다", message: "EV Infra의 원활한 기능을 이용하시려면 모든 권한을 허용해 주십시오.\n[설정] > [EV Infra] 에서 권한을 허용할 수 있습니다.", preferredStyle: UIAlertControllerStyle.alert)


        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        alertController.addAction(openAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    internal func myLocationModeOff() {
        tMapView?.setTrackingMode(false)
        tMapView?.setCompassMode(false)
        updateMyLocationButton()
    }
    
    internal func updateMyLocationButton() {
        if let tMapView = tMapView {
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                DispatchQueue.main.async {
                    // Run UI Updates or call completion block
                    if tMapView.getIsCompass() {
                        self.myLocationButton.setImage(UIImage(named: "ic_my_location_compass"), for: .normal)
                        UIApplication.shared.isIdleTimerDisabled = true // 화면 켜짐 유지
                    } else if tMapView.getIsTracking() {
                        self.myLocationButton.setImage(UIImage(named: "ic_my_location_tracking"), for: .normal)
                        UIApplication.shared.isIdleTimerDisabled = true // 화면 켜짐 유지
                    } else {
                        self.myLocationButton.setImage(UIImage(named: "ic_my_location_off"), for: .normal)
                        UIApplication.shared.isIdleTimerDisabled = false // 화면 켜짐 유지 끔
                    }
                }
            }
        }
    }
    
    // 더 이상 보지 않기 한 광고가 정해진 기간을 넘겼는지 체크 및 광고 노출
    private func showStartAd() {
        let window = UIApplication.shared.keyWindow!
        
        let keepDateStr = UserDefault().readString(key: UserDefault.Key.AD_KEEP_DATE_FOR_A_WEEK)
        if keepDateStr.isEmpty {
            window.addSubview(AdvertisingDialog(frame: window.bounds))
        } else {
            if let keepDate = Date().toDate(data: keepDateStr) {
                let difference = NSCalendar.current.dateComponents([.day], from: keepDate, to: Date());
                if let day = difference.day {
                    if day > 3 {
                        window.addSubview(AdvertisingDialog(frame: window.bounds))
                    }
                }
            } else {
                window.addSubview(AdvertisingDialog(frame: window.bounds))
            }
        }
    }
    
    private func checkFCM() {
        if let notification = FCMManager.sharedInstance.fcmNotification {
            FCMManager.sharedInstance.alertMessage(navigationController: appDelegate.navigationController, data: notification)
        }
    }
    
    private func menuBadgeAdd() {
        if Board.sharedInstance.hasNew() {
            appDelegate.appToolbarController.setMenuIcon(hasBadge: true)
        } else {
            appDelegate.appToolbarController.setMenuIcon(hasBadge: false)
        }
    }
    
    func prepareClustering() {
        clustering = ClusterManager.init(mapView: tMapView!)
        clustering?.isClustering = defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)
//        clustering?.clusterDelegate = self
    }
    
    func updateClustering() {
        if (clustering?.isClustering != defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)) {
            clustering?.isClustering = defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)
            if (clustering?.isClustering)! {
                clustering?.removeChargerForClustering(zoomLevel: (tMapView?.getZoomLevel())!)
            } else {
                clustering?.removeClusterFromSettings()
            }

            drawTMapMarker()
        }
    }
}

extension MainViewController {
    
    func prepareMenuBtnLayer() {
        chargingStatus()
        
        btn_main_offerwall.alignTextUnderImage()
        btn_main_offerwall.tintColor = UIColor(rgb: 0x15435C)
        btn_main_offerwall.setImage(UIImage(named: "ic_line_offerwall")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        btn_main_help.alignTextUnderImage()
        btn_main_help.tintColor = UIColor(rgb: 0x15435C)
        btn_main_help.setImage(UIImage(named: "ic_line_help")?.withRenderingMode(.alwaysTemplate), for: .normal)

        btn_main_favorite.alignTextUnderImage()
        btn_main_favorite.tintColor = UIColor(rgb: 0x15435C)
        btn_main_favorite.setImage(UIImage(named: "ic_line_favorite")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    @IBAction func onClickMainCharge(_ sender: UIButton) {
        if MemberManager().isLogin() {
            Server.getChargingId { (isSuccess, responseData) in
                if isSuccess {
                    let json = JSON(responseData)
                    self.responseGetChargingId(response: json)
                }
            }
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    @IBAction func onClickMainOfferwall(_ sender: UIButton) {
        if MemberManager().isLogin() {
            let offerwallStoryboard = UIStoryboard(name : "Offerwall", bundle: nil)
            let offerwallVC = offerwallStoryboard.instantiateViewController(withIdentifier: "OfferwallViewController") as! OfferwallViewController
            self.navigationController?.push(viewController: offerwallVC)
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    @IBAction func onClickMainHelp(_ sender: UIButton) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsViewControll = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        termsViewControll.tabIndex = .Help
        self.navigationController?.push(viewController: termsViewControll)
//        if MemberManager().isLogin() {
//            let reportChargeVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportChargeViewController") as! ReportChargeViewController
//            reportChargeVC.info.from = Const.REPORT_CHARGER_FROM_MAIN
//            self.present(AppSearchBarController(rootViewController: reportChargeVC), animated: true, completion: nil)
//        } else {
//            MemberManager().showLoginAlert(vc: self)
//        }
    }
    
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
}

extension MainViewController {
    func responseGetChargingId(response: JSON) {
        if response.isEmpty {
            return
        }
        
        switch (response["code"].intValue) {
        case 1000:
            defaults.saveString(key: UserDefault.Key.CHARGING_ID, value: response["charging_id"].stringValue)
            let paymentStoryboard = UIStoryboard(name : "Payment", bundle: nil)
            let paymentStatusVC = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentStatusViewController") as! PaymentStatusViewController
            paymentStatusVC.cpId = response["cp_id"].stringValue
            paymentStatusVC.connectorId = response["connector_id"].stringValue
            
            self.navigationController?.push(viewController: paymentStatusVC)
            
        case 2002:
            let paymentStoryboard = UIStoryboard(name : "Payment", bundle: nil)
            let paymentQRScanVC = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentQRScanViewController") as! PaymentQRScanViewController
            self.navigationController?.push(viewController:paymentQRScanVC)
            
            defaults.removeObjectForKey(key: UserDefault.Key.CHARGING_ID)
            
        default:
            defaults.removeObjectForKey(key: UserDefault.Key.CHARGING_ID)
        }
    }
    
    func chargingStatus() {
        if MemberManager().isLogin() {
            Server.getChargingId { (isSuccess, responseData) in
                if isSuccess {
                    let json = JSON(responseData)
                    self.getChargingStatus(response: json)
                }
            }
        } else {
            // 진행중인 충전이 없음
            self.btn_main_charge.alignTextUnderImage()
            self.btn_main_charge.tintColor = UIColor(rgb: 0x15435C)
            self.btn_main_charge.setImage(UIImage(named: "ic_line_payment")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.btn_main_charge.setTitle("간편 충전", for: .normal)
        }
    }
    
    func getChargingStatus(response: JSON) {
        switch (response["code"].intValue) {
        case 1000:
            // 충전중
            self.btn_main_charge.alignTextUnderImage()
            self.btn_main_charge.setImage(UIImage(named: "ic_line_charging")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.btn_main_charge.tintColor = UIColor(rgb: 0x15435C)
            self.btn_main_charge.setTitle("충전중", for: .normal)
            break

        case 2002:
            // 진행중인 충전이 없음
            self.btn_main_charge.alignTextUnderImage()
            self.btn_main_charge.tintColor = UIColor(rgb: 0x15435C)
            self.btn_main_charge.setImage(UIImage(named: "ic_line_payment")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.btn_main_charge.setTitle("간편 충전", for: .normal)
            break
            
        default:
            break
        }
    }
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
