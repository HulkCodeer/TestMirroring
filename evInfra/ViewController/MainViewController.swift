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
//    @IBOutlet weak var btnRouteAdd: UIButton!
    
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
//    @IBOutlet weak var callOutStatusBar: UIView!
    @IBOutlet weak var callOutStatus: UILabel!
    @IBOutlet weak var callOutTitle: UILabel!
    @IBOutlet weak var callOutFavorite: UIButton!
    
    @IBOutlet var chargePriceLb: UILabel!
    @IBOutlet var chargePowerLb: UILabel!
    
    @IBOutlet var distanceLb: UILabel!
    
    @IBOutlet var typeLb1: UILabel!
    @IBOutlet var typeLb2: UILabel!
    @IBOutlet var typeLb3: UILabel!
    
    @IBOutlet var markerImg: UIImageView!
    
//    @IBOutlet weak var callOutDCCombo: UIImageView!
//    @IBOutlet weak var callOutDCDemo: UIImageView!
//    @IBOutlet weak var callOutAC: UIImageView!
//    @IBOutlet weak var callOutSlow: UIImageView!
    
    @IBOutlet weak var startPointBtn: UIButton!
    @IBOutlet weak var endPointBtn: UIButton!
    @IBOutlet weak var naviBtn: UIButton!
    
    // Menu Button Layer
    @IBOutlet weak var btn_menu_layer: UIView!
    @IBOutlet weak var btn_main_charge: UIButton!
    @IBOutlet weak var btn_main_payable_charger_list: UIButton!
    @IBOutlet weak var btn_main_report_charger: UIButton!
    @IBOutlet weak var btn_main_favorite: UIButton!
    
    //경로찾기시 거리표시 뷰 (call out)
    @IBOutlet weak var routeDistanceView: UIView!
    @IBOutlet weak var routeDistanceLabel: UILabel!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var tMapView: TMapView? = nil
    private var tMapPathData: TMapPathData = TMapPathData.init()
    private var routeStartPoint: TMapPoint? = nil
    private var routeEndPoint: TMapPoint? = nil
    private var resultTableView: PoiTableView?
    
    private var selectCharger: ChargerStationInfo? = nil
    
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
        
        prepareNotificationCenter()
        prepareCalloutLayer()
        prepareClustering()
        prepareMenuBtnLayer()
        
        requestStationInfo();
        
        //getChargerInfo()  // request to server
        //self.checkFCM()
        prepareChargePrice()
    }
    
    override func viewWillLayoutSubviews() {
        self.startPointBtn.setBorderRadius([.bottomLeft, .topLeft], radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
        self.endPointBtn.setBorderRadius([.bottomRight, .topRight], radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
        self.naviBtn.setBorderRadius(.allCorners, radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        menuBadgeAdd()
        updateClustering()
        if self.sharedChargerId != nil {
            self.selectChargerFromShared()
        }
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
//            cell.setChecked(isChecked: cell.isSelected)
            cell.setChecked(isChecked: companyVisibilityList[index])
        }
        
        dropDownCompany.multiSelectionAction = { [unowned self] (indexes, item) in
            let isAllSelected = companyVisibilityList[0]
            self.dropDownCompany.clearSelection()
            for (idx, _) in companyVisibilityList.enumerated() {
//                self.dropDownCompany.deselectRow(idx)
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
        
        dropDownCompany.willShowAction = { [unowned self] in
            for (index, comVisible) in companyVisibilityList.enumerated(){
                if comVisible {
                    self.dropDownCompany.selectRow(index)
                } else {
                    self.dropDownCompany.deselectRow(index)
                    if companyVisibilityList[0] {
                        companyVisibilityList[0] = false
                        self.dropDownCompany.deselectRow(0)
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
            print("[Main] TMap을 생성하는 데 실패했습니다")
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
    
    @objc func onClickChargePrice(sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChargePriceViewController") as! ChargePriceViewController
        self.navigationController?.push(viewController:vc)
    }
    
    @IBAction func onClickFavorite(_ sender: UIButton) {
        if MemberManager().isLogin() {
            ChargerManager.sharedInstance.setFavoriteCharger(charger: selectCharger!) { (charger) in
                 self.setCallOutFavoriteIcon(charger: charger)
            }
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    // MARK: - Action for button
    @IBAction func onClickMyLocation(_ sender: UIButton) {
        if let mapView = tMapView {
            if mapView.getIsTracking() {
                tMapView?.setCompassMode(true)
            } else {
                tMapView?.setTrackingMode(true)
            }
            updateMyLocationButton()
        }
    }
    
    @IBAction func onClickRenewBtn(_ sender: UIButton) {
        if !self.markerIndicator.isAnimating {
            self.refreshChargerInfo()
        }
    }
    
    @IBAction func onClickRouteStartPoint(_ sender: UIButton) {
//        String snackText = mSelectedCharger.mSnm + "(이)가 출발지로 설정되었습니다.";
//        Snackbar snackBar = Snackbar.make(v, snackText, Snackbar.LENGTH_SHORT).setAction("Action", null);
//        UtilFont.setGlobalFont(this, snackBar.getView());
//        snackBar.show();

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
    
    @IBAction func onClickRouteEndPoint(_ sender: UIButton) {
        if self.selectCharger != nil {
            guard let tc = toolbarController else {
                return
            }
            let appTc = tc as! AppToolbarController
            appTc.enableRouteMode(isRoute: true)
            
            endField.text = selectCharger?.mStationInfoDto?.mSnm
            routeStartPoint = selectCharger?.getTMapPoint()
        }
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
            let searchVC:SearchViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
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
        startField.placeholder = "출발지를 입력하세요"
        startField.placeholderAnimation = .hidden
        startField.isClearIconButtonEnabled = true
//        startField.dividerActiveColor = Color.blue.darken1
        startField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        endField.tag = ROUTE_END
        endField.delegate = self
        endField.placeholder = "도착지를 입력하세요"
        endField.placeholderAnimation = .hidden
        endField.isClearIconButtonEnabled = true
        endField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        btnRouteCancel.addTarget(self, action: #selector(onClickRouteCancel(_:)), for: .touchUpInside)
        btnRoute.addTarget(self, action: #selector(onClickRoute(_:)), for: .touchUpInside)
        
//        btnRouteAdd.isEnabled = false
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
        hideKeyboard()
        hideResultView()
        setView(view: routeDistanceView, hidden: true)
        
        startField.text = ""
        endField.text = ""
        
        routeStartPoint = nil
        routeEndPoint = nil
        
//        btnRouteAdd.isEnabled = false
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
        if routeStartPoint == nil {
            if let currentPoint = MainViewController.currentLocation {
                startField.text = tMapPathData.convertGpsToAddress(at: currentPoint)
                routeStartPoint = currentPoint
            }
        }
        
        if let startPoint = routeStartPoint, let endPoint = routeEndPoint {
            markerIndicator.startAnimating()
            
            // 키보드 숨기기
            hideKeyboard()
            
            // 검색 결과창 숨기기
            hideResultView()
            
            // 하단 충전소 정보 숨기기
            setView(view: callOutLayer, hidden: true)
            
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
//            btnRouteAdd.isEnabled = true
            btnRouteCancel.setTitle("경로취소", for: .normal)
            
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
            strDistance = NSString(format: "목적지까지의 거리는 %dKm 입니다", Int(distance/1000))
        } else {
            strDistance = NSString(format: "목적지까지의 거리는 %dm 입니다", Int(distance))
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
        let detailVC:DetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.mainViewDelegate = self
        detailVC.charger = self.selectCharger
        detailVC.checklistUrl = self.checklistUrl
        self.navigationController?.push(viewController: detailVC, subtype: kCATransitionFromTop)
    }
    
    func selectCharger(chargerId: String) {
        myLocationModeOff()
        
        // 이전에 선택된 충전소 마커를 원래 마커로 원복
        if selectCharger != nil {
            if let markerItem = tMapView!.getMarketItem(fromID: selectCharger!.mChargerId) {
                markerItem.setIcon(selectCharger!.getMarkerIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
                
            }
            selectCharger = nil
        }
        
        // 선택한 충전소 정보 표시
        if let selectCharger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId){
            showCallOut(charger: selectCharger)
        } else {
            print("Not Found Charger \(ChargerManager.sharedInstance.getChargerStationInfoList().count)")
        }
    }
    
    func showCallOut(charger: ChargerStationInfo) {
        selectCharger = charger
        if (selectCharger?.mTotalType != nil){
            setChargerTypeImage(type: (selectCharger?.mTotalType)!)
            setChargerPower(power: (selectCharger?.mPower)!, type: (selectCharger?.mTotalType)!)
            setChargePrice(pay: (selectCharger?.mStationInfoDto?.mPay)!)
        }
        setDistance()
       
//        callOutStatusBar.backgroundColor = selectCharger?.cidInfo.getCstColor(cst: selectCharger?.mTotalStatus ?? 2)
        callOutTitle.text = selectCharger?.mStationInfoDto?.mSnm
        
        callOutStatus.textColor = selectCharger?.cidInfo.getCstColor(cst: selectCharger?.mTotalStatus ?? 2)
        callOutStatus.text = selectCharger?.cidInfo.cstToString(cst: selectCharger?.mTotalStatus ?? 2)
        
        //TODO: 수정예정
        let chargeState = callOutStatus.text
        setChargeStateImg(type: chargeState!)
        
        setCallOutFavoriteIcon(charger: selectCharger!)
        
        setView(view: callOutLayer, hidden: false)

        if let markerItem = self.tMapView!.getMarketItem(fromID: self.selectCharger!.mChargerId) {
            if (markerItem.getIcon().isEqual(other: self.selectCharger!.getSelectIcon())) == false {
                markerItem.setIcon(self.selectCharger!.getSelectIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
            }
        }
    }
    
    func setCallOutFavoriteIcon(charger: ChargerStationInfo) {
        if charger.mFavorite {
            callOutFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
        } else {
            callOutFavorite.setImage(UIImage(named: "ic_favorite_add"), for: .normal)
        }
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    //TODO: detailViewController 코드 겹침
    func setDistance() {
        if let currentLocatin = MainViewController.currentLocation {
            getDistance(curPos: currentLocatin, desPos: self.selectCharger!.marker.getTMapPoint())
        } else {
            self.distanceLb.text = "현재 위치를 받아오지 못했습니다."
        }
    }
    
    func getDistance(curPos: TMapPoint, desPos: TMapPoint) {
        if desPos.getLatitude() == 0 || desPos.getLongitude() == 0 {
            self.distanceLb.text = "현재 위치를 받아오지 못했습니다."
        } else {
            self.distanceLb.text = "계산중"
            
            DispatchQueue.global(qos: .background).async {
                let tMapPathData = TMapPathData.init()
                if let path = tMapPathData.find(from: curPos, to: desPos) {
                    let distance = Double(path.getDistance() / 1000).rounded()

                    DispatchQueue.main.async {
                        self.distanceLb.text = "| \(distance) Km"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.distanceLb.text = "거리를 계산할 수 없습니다."
                    }
                }
            }
        }
    }
    
    func setChargerTypeImage(type:Int) {
        self.typeLb1.text = ""
        self.typeLb2.text = ""
        self.typeLb3.text = ""
        
        if (type & Const.CTYPE_DCDEMO) == Const.CTYPE_DCDEMO {
            let type = "CD차데모"
            setTextType(type:type)
        }
        if (type & Const.CTYPE_DCCOMBO) == Const.CTYPE_DCCOMBO {
            let type = "CD콤보"
            setTextType(type:type)
        }
        if (type & Const.CTYPE_AC) == Const.CTYPE_AC {
            let type = "AC3상"
            setTextType(type:type)
        }
        
        if (type & Const.CTYPE_SLOW) == Const.CTYPE_SLOW {
            let type = "완속"
            setTextType(type:type)
        }
        
        if ((type & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER)
            || ((type & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION) {
//            callOutDCCombo.image = nil
//            callOutSlow.image = nil
//            callOutDCDemo.image = UIImage(named: "type_super_dim")
//            callOutAC.image =  UIImage(named: "type_destination_dim")
            
            if (type & Const.CTYPE_SUPER_CHARGER) == Const.CTYPE_SUPER_CHARGER {
                let type = "슈퍼차저"
                setTextType(type:type)
            }
            
            if (type & Const.CTYPE_DESTINATION) == Const.CTYPE_DESTINATION {
                let type = "데스티네이션"
                setTextType(type:type)
            }
        }
    }

    
    func setTextType(type:String) {
        
        if self.typeLb1.text == ""{
            self.typeLb1.text = type
            print("csj_lb1", type)
        }else if self.typeLb2.text == ""{
            self.typeLb2.text = type
            print("csj_lb2", type)
        }else {
            self.typeLb3.text = type
            print("csj_lb3", type)
        }

    }
    
    func setChargerPower(power:Int, type:Int) {
        var strPower = ""
        if power == 0{
            if ((type & Const.CTYPE_DCDEMO) > 0 ||
                                (type & Const.CTYPE_DCCOMBO) > 0 ||
                                (type & Const.CTYPE_AC) > 0) {
                                strPower = "50kWh"
            } else if ((type & Const.CTYPE_SLOW) > 0 ||
                    (type & Const.CTYPE_DESTINATION) > 0) {
                strPower = "완속"
            } else if ((type & Const.CTYPE_HYDROGEN) > 0) {
                strPower = "수소"
            } else if ((type & Const.CTYPE_SUPER_CHARGER) > 0) {
                strPower = "110kWh 이상"
            } else {
                strPower = "-"
            }
        }else{
            strPower = "\(power)kWh"
        }
        self.chargePowerLb.text = strPower
    }
    
    func setChargeStateImg(type:String) {
        switch type {
        case "충전중":
            self.markerImg.backgroundColor = UIColor(patternImage: UIImage(named: "marker_state_charging.png")!)
            break
        case "대기중":
            self.markerImg.backgroundColor = UIColor(patternImage: UIImage(named: "marker_state_normal.png")!)
            break
        case "운영중지":
            self.markerImg.backgroundColor = UIColor(patternImage: UIImage(named: "marker_state_no_op.png")!)
            break
        default:
            self.markerImg.backgroundColor = UIColor(patternImage: UIImage(named: "marker_state_no_connect.png")!)
            break
        }
    }
    
    func setChargePrice(pay: String) {
        // 과금
        switch pay {
        case "Y":
            self.chargePriceLb.text = "무료"
        case "N":
            self.chargePriceLb.text = "유료"
        default:
            self.chargePriceLb.text = "시범운영"
        }
    }
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
            }()
            )
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
}

extension MainViewController {
    func prepareNotificationCenter() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(saveLastZoomLevel), name: .UIApplicationDidEnterBackground, object: nil)
        center.addObserver(self, selector: #selector(updateMemberInfo), name: Notification.Name("updateMemberInfo"), object: nil)
        center.addObserver(self, selector: #selector(getSharedChargerId(_:)), name: Notification.Name("kakaoScheme"), object: nil)
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
    
    func selectChargerFromShared() {
        if let id = self.sharedChargerId {
            self.selectCharger(chargerId: id)
            self.sharedChargerId = nil
            if let sharedCharger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: id) {
                self.tMapView?.setCenter(sharedCharger.getTMapPoint())
            }
        }
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
        if NewArticleChecker.sharedInstance.hasNew() {
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
        btn_main_charge.alignTextUnderImage()
        btn_main_charge.tintColor = UIColor(rgb: 0x15435C)
        btn_main_charge.setImage(UIImage(named: "ic_line_payment")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        btn_main_payable_charger_list.alignTextUnderImage()
        btn_main_payable_charger_list.tintColor = UIColor(rgb: 0x15435C)
        btn_main_payable_charger_list.setImage(UIImage(named: "ic_line_can_payment")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        btn_main_favorite.alignTextUnderImage()
        btn_main_favorite.tintColor = UIColor(rgb: 0x15435C)
        btn_main_favorite.setImage(UIImage(named: "ic_line_favorite_folder")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        btn_main_report_charger.alignTextUnderImage()
        btn_main_report_charger.tintColor = UIColor(rgb: 0x15435C)
        btn_main_report_charger.setImage(UIImage(named: "ic_line_report")?.withRenderingMode(.alwaysTemplate), for: .normal)
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
    
    @IBAction func onClickMainPayableChargerList(_ sender: UIButton) {
        //UIAlertController.showMessage("전국 한전(단,아파트제외), GS칼텍스, 에스트래픽 충전기에서 이용해 보세요.^^")
        if MemberManager().isLogin() {
            let offerwallVC = self.storyboard?.instantiateViewController(withIdentifier: "OfferwallViewController") as! OfferwallViewController
            
            let next = AppSearchBarController(rootViewController: offerwallVC)
            next.modalPresentationStyle = .fullScreen
            self.present(next, animated: true, completion: nil)
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    @IBAction func onClickMainReportCharger(_ sender: UIButton) {
        if MemberManager().isLogin() {
            let reportChargeVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportChargeViewController") as! ReportChargeViewController
            reportChargeVC.info.from = Const.REPORT_CHARGER_FROM_MAIN
            self.present(AppSearchBarController(rootViewController: reportChargeVC), animated: true, completion: nil)
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    @IBAction func onClickMainFavorite(_ sender: UIButton) {
        if MemberManager().isLogin() {
            let favoriteVC:FavoriteViewController = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
            favoriteVC.delegate = self
            self.present(AppSearchBarController(rootViewController: favoriteVC), animated: true, completion: nil)
        } else {
            MemberManager().showLoginAlert(vc:self)
        }
    }
}

extension MainViewController {
    func responseGetChargingId(response: JSON) {
        if response.isEmpty {
            return
        }
        
        switch (response["code"].intValue) {
        case 1000:
            defaults.saveString(key: UserDefault.Key.CHARGING_ID, value: response["charging_id"].stringValue)
            let paymentStatusVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentStatusViewController") as! PaymentStatusViewController
            paymentStatusVC.cpId = response["cp_id"].stringValue
            paymentStatusVC.connectorId = response["connector_id"].stringValue
            
            self.navigationController?.push(viewController: paymentStatusVC)
            
        case 2002:
            let paymentQRScanVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentQRScanViewController") as! PaymentQRScanViewController
            self.navigationController?.push(viewController:paymentQRScanVC)
            
            defaults.removeObjectForKey(key: UserDefault.Key.CHARGING_ID)
            
        default:
            defaults.removeObjectForKey(key: UserDefault.Key.CHARGING_ID)
        }
    }
}
