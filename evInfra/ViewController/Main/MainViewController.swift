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
    
    @IBOutlet weak var filterBarView: FilterBarView!
    @IBOutlet weak var filterContainerView: FilterContainerView!
    @IBOutlet weak var filterHeight: NSLayoutConstraint!
    
    @IBOutlet weak var startField: TextField!
    @IBOutlet weak var endField: TextField!
    
    @IBOutlet weak var btnRouteCancel: UIButton!
    @IBOutlet weak var btnRoute: UIButton!
    
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
    
    static var currentLocation: TMapPoint? = nil
    private var searchLocation: TMapPoint? = nil
    var sharedChargerId: String? = nil
    
    private var loadedChargers = false
    private var clustering: ClusterManager? = nil
    private var currentClusterLv = 0
    private var isAllowedCluster = true
    private var canIgnoreJejuPush = true
    
    private var summaryView:SummaryView!
    
    // 지킴이 점겸표 url
    private var checklistUrl: String?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        showGuide()
        prepareRouteField()
        preparePOIResultView()
        prepareFilterView()
        prepareMapView()
        
        prepareSummaryView()
        prepareNotificationCenter()
        prepareRouteView()
        prepareClustering()
        prepareMenuBtnLayer()
        
        prepareChargePrice()
        requestStationInfo()
        
        prepareCalloutLayer()
    }
    
    override func viewWillLayoutSubviews() {
        prepareSummaryView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
    
    func showDeepLink() {
        DeepLinkPath.sharedInstance.runDeepLink(navigationController: navigationController!)
    }

    // Filter
    func prepareFilterView() {
        filterBarView.delegate = self
        filterContainerView.delegate = self
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
        myLocationButton.layer.cornerRadius = 20
        myLocationButton.layer.borderWidth = 1
        myLocationButton.layer.borderColor = UIColor.init(named: "border-opaque")?.cgColor
        updateMyLocationButton()
        
        reNewButton.layer.cornerRadius = 20
        reNewButton.layer.borderWidth = 1
        reNewButton.layer.borderColor = UIColor.init(named: "border-opaque")?.cgColor

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
            
            self.setStartPath()
        }
    }
    
    func setStartPath() {
        if self.selectCharger != nil {
            let passList = [selectCharger?.getTMapPoint()]
            findPath(passList: passList as! [TMapPoint])
        }
    }
    
    func showNavigation() {
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
    
    @objc func onClickShowNavi(_ sender: Any) {
        self.showNavigation()
    }
}

extension MainViewController: DelegateChargerFilterView {
    func onApplyFilter() {
        filterContainerView.updateFilters()
        filterBarView.updateTitle()
        // refresh marker
        self.drawTMapMarker()
    }
}

extension MainViewController: DelegateFilterContainerView {
    func swipeFilterTo(type: FilterType) {
        filterBarView.updateView(newSelect: type)
    }
    
    func changedFilter(type: FilterType) {
        filterBarView.updateTitleByType(type: type)
        // refresh marker
        self.drawTMapMarker()
    }
}

extension MainViewController: DelegateFilterBarView {
    func showFilterContainer(type: FilterType){
        // change or remove containerview
        if (filterContainerView.isSameView(type: type)){
            hideFilter()
        } else {
            showFilter()
            filterContainerView.showFilterView(type: type)
        }
    }
    
    func hideFilter(){
        filterBarView.updateView(newSelect: .none)
        filterContainerView.isHidden = true
        filterHeight.constant = routeView.layer.height + filterBarView.layer.height
        filterView.sizeToFit()
        filterView.layoutIfNeeded()
    }
    
    func showFilter(){
        filterContainerView.isHidden = false
        filterHeight.constant = routeView.layer.height + filterBarView.layer.height + filterContainerView.layer.height
        filterView.sizeToFit()
        filterView.layoutIfNeeded()
    }
    
    func startFilterSetting(){
        // chargerFilterViewcontroller
        let filterStoryboard = UIStoryboard(name : "Filter", bundle: nil)
        let chargerFilterVC:ChargerFilterViewController = filterStoryboard.instantiateViewController(withIdentifier: "ChargerFilterViewController") as! ChargerFilterViewController
        chargerFilterVC.delegate = self
        self.navigationController?.push(viewController: chargerFilterVC)
    }
    
    @IBAction func onClickMainFavorite(_ sender: UIButton) {
        if MemberManager().isLogin() {
            let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
            let favoriteVC:FavoriteViewController = memberStoryboard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
            favoriteVC.delegate = self
            self.present(AppSearchBarController(rootViewController: favoriteVC), animated: true, completion: nil)
        } else {
            MemberManager().showLoginAlert(vc:self)
        }
    }
}

extension MainViewController {
    internal func drawTMapMarker() {
        if !ChargerManager.sharedInstance.isReady() { return }

        self.clustering?.clustering(filter: FilterManager.sharedInstance.filter, loadedCharger: self.loadedChargers)
        
        if !self.loadedChargers {
            self.loadedChargers = true
            if self.sharedChargerId != nil {
                self.selectChargerFromShared()
            }
        }
        if searchLocation != nil {
            let poiItem = TMapPOIItem(tMapPoint: searchLocation)
            poiItem!.setIcon(UIImage(named: "marker_search"), anchorPoint: CGPoint(x: 0.5, y: 1.0))
            tMapView?.removeCustomObject("search")
            tMapView?.addCustomObject(poiItem, id: "search")
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
        
        self.clustering?.isRouteMode = false
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clustering!.isRouteMode)

        drawTMapMarker()
    }
    
    func findPath(passList: [TMapPoint]) {
        if routeStartPoint == nil{
            
            selectCharger?.mStationInfoDto?.mLongitude = routeEndPoint?.getLongitude()
            selectCharger?.mStationInfoDto?.mLatitude = routeEndPoint?.getLatitude()
            
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
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clustering!.isRouteMode)

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
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clustering!.isRouteMode)
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
        hideFilter()
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
            searchLocation = TMapPoint(lon: lon, lat: lat)
            let poiItem = TMapPOIItem(tMapPoint: searchLocation)
            poiItem!.setIcon(UIImage(named: "marker_search"), anchorPoint: CGPoint(x: 0.5, y: 1.0))
            tMapView?.removeCustomObject("search")
            tMapView?.addCustomObject(poiItem, id: "search")
        }
    }
    
    func moveToSelected(chargerId: String) {
        if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId){
            self.tMapView?.setZoomLevel(15)
            self.tMapView?.setCenter(charger.getTMapPoint())
            
            searchLocation = nil
            tMapView?.removeCustomObject("search")
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                DispatchQueue.main.async {
                    self.selectCharger(chargerId: chargerId)
                }
            }
        }
    }
    
    func prepareCalloutLayer() {
        callOutLayer.isHidden = true
        addCalloutClickListener()
    }
    
    func addCalloutClickListener() {
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onClickCalloutLayer (_:)))
        self.callOutLayer.addGestureRecognizer(gesture)
    }
    
    @objc func onClickCalloutLayer(_ sender:UITapGestureRecognizer) {
        let detailStoryboard = UIStoryboard(name : "Detail", bundle: nil)
        let detailVC:DetailViewController = detailStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.charger = self.selectCharger
        detailVC.isRouteMode = self.clustering!.isRouteMode
        
        self.navigationController?.push(viewController: detailVC, subtype: kCATransitionFromTop)
    }
    
    func prepareSummaryView() {
        let window = UIApplication.shared.keyWindow!
        callOutLayer.frame.size.width = window.frame.width
        if summaryView == nil {
            summaryView = SummaryView(frame: callOutLayer.frame.bounds)
        }
        summaryView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        callOutLayer.addSubview(summaryView)
//        summaryView.delegate = self
    }
    
    func selectCharger(chargerId: String) {
        
        myLocationModeOff()
        
        // 이전에 선택된 충전소 마커를 원래 마커로 원복
        if selectCharger != nil {
            summaryView.layoutIfNeeded()
            callOutLayer.layoutIfNeeded()
                        
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
        summaryView.charger = charger
        summaryView.setLayoutType(charger: charger, type: SummaryView.SummaryType.MainSummary)
//        getStationDetailInfo()
        setView(view: callOutLayer, hidden: false)
        
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clustering!.isRouteMode)

        if let markerItem = self.tMapView!.getMarketItem(fromID: self.selectCharger!.mChargerId) {
            if (markerItem.getIcon().isEqual(other: self.selectCharger!.getSelectIcon())) == false {
                markerItem.setIcon(self.selectCharger!.getSelectIcon(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
            }
        }
    }
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
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
                    controller?.showDeepLink()
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
}

extension MainViewController {
    func prepareNotificationCenter() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(saveLastZoomLevel), name: .UIApplicationDidEnterBackground, object: nil)
        center.addObserver(self, selector: #selector(updateMemberInfo), name: Notification.Name("updateMemberInfo"), object: nil)
        center.addObserver(self, selector: #selector(getSharedChargerId(_:)), name: Notification.Name("kakaoScheme"), object: nil)
        // [Summary observer]
        center.addObserver(self, selector: #selector(directionStartPoint(_:)), name: Notification.Name(summaryView.startKey), object: nil)
        center.addObserver(self, selector: #selector(directionStartPath(_:)), name: Notification.Name(summaryView.addKey), object: nil)
        center.addObserver(self, selector: #selector(directionEnd(_:)), name: Notification.Name(summaryView.endKey), object: nil)
        center.addObserver(self, selector: #selector(directionNavigation(_:)), name: Notification.Name(summaryView.navigationKey), object: nil)
        center.addObserver(self, selector: #selector(requestLogIn(_:)), name: Notification.Name(summaryView.loginKey), object: nil)
        center.addObserver(self, selector: #selector(isChangeFavorite(_:)), name: Notification.Name(summaryView.favoriteKey), object: nil)
    }
    func removeObserver() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name("updateMemberInfo"), object: nil)
    }
    
    func removeSummaryObserver() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name(summaryView.startKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.endKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.addKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.navigationKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.loginKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.favoriteKey), object: nil)
    }
    
    @objc func saveLastZoomLevel() {
        if let tmapview = self.tMapView {
            UserDefault().saveInt(key: UserDefault.Key.MAP_ZOOM_LEVEL, value: tmapview.getZoomLevel())
        }
    }
    
    @objc func updateMemberInfo() {
        FilterManager.sharedInstance.saveTypeFilterForCarType()
        filterContainerView.updateFilters()
        filterBarView.updateTitle()
        drawTMapMarker()
    }
    
    @objc func getSharedChargerId(_ notification: NSNotification) {
        let sharedid = notification.userInfo?["sharedid"] as! String
        self.sharedChargerId = sharedid
        if self.loadedChargers {
            selectChargerFromShared()
        }
    }
    
    @objc func directionStartPoint(_ notification: NSNotification) {
        selectCharger = (notification.object as! ChargerStationInfo)
        if navigationDrawerController?.isOpened == true{
            navigationDrawerController?.toggleLeftView()
        }
        self.navigationController?.popToRootViewController(animated: true)
        self.setStartPoint()
    }
    
    @objc func directionStartPath(_ notification: NSNotification) {
        selectCharger = (notification.object as! ChargerStationInfo)
        if navigationDrawerController?.isOpened == true{
            navigationDrawerController?.toggleLeftView()
        }
        self.navigationController?.popToRootViewController(animated: true)
        self.setStartPath()
    }
        
    @objc func directionEnd(_ notification: NSNotification) {
        selectCharger = (notification.object as! ChargerStationInfo)
        if navigationDrawerController?.isOpened == true{
            navigationDrawerController?.toggleLeftView()
        }
        self.navigationController?.popToRootViewController(animated: true)
        self.setEndPoint()
    }
    
    @objc func directionNavigation(_ notification: NSNotification) {
        selectCharger = (notification.object as! ChargerStationInfo)
        self.showNavigation()
    }
    
    @objc func requestLogIn(_ notification: NSNotification) {
        MemberManager().showLoginAlert(vc: self)
    }
    
    @objc func isChangeFavorite(_ notification: NSNotification) {
        let changed = (notification.object as! Bool)
        summaryView.setCallOutFavoriteIcon(favorite: changed)
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
                        self.myLocationButton.setImage(UIImage(named: "icon_compass_lg"), for: .normal)
                        self.myLocationButton.tintColor = UIColor.init(named: "content-positive")
                        UIApplication.shared.isIdleTimerDisabled = true // 화면 켜짐 유지
                    } else if tMapView.getIsTracking() {
                        self.myLocationButton.setImage(UIImage(named: "icon_current_location_lg"), for: .normal)
                        self.myLocationButton.tintColor = UIColor.init(named: "content-positive")
                        UIApplication.shared.isIdleTimerDisabled = true // 화면 켜짐 유지
                    } else {
                        self.myLocationButton.setImage(UIImage(named: "icon_current_location_lg"), for: .normal)
                        self.myLocationButton.tintColor = UIColor.init(named: "content-primary")
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
    
    private func showGuide() {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(GuideAlertDialog(frame: window.bounds))
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
        btn_main_offerwall.tintColor = UIColor(named: "gr-8")
        btn_main_offerwall.setImage(UIImage(named: "ic_line_offerwall")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        btn_main_help.alignTextUnderImage()
        btn_main_help.tintColor = UIColor(named: "gr-8")
        btn_main_help.setImage(UIImage(named: "ic_line_help")?.withRenderingMode(.alwaysTemplate), for: .normal)

        btn_main_favorite.alignTextUnderImage()
        btn_main_favorite.tintColor = UIColor(named: "gr-8")
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
        termsViewControll.tabIndex = .FAQTop
        self.navigationController?.push(viewController: termsViewControll)
        
        // 원래주석된 코드
//        if MemberManager().isLogin() {
//            let reportChargeVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportChargeViewController") as! ReportChargeViewController
//            reportChargeVC.info.from = Const.REPORT_CHARGER_FROM_MAIN
//            self.present(AppSearchBarController(rootViewController: reportChargeVC), animated: true, completion: nil)
//        } else {
//            MemberManager().showLoginAlert(vc: self)
//        }
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
            self.btn_main_charge.tintColor = UIColor(named: "gr-8")
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
            self.btn_main_charge.tintColor = UIColor(named: "gr-8")
            self.btn_main_charge.setTitle("충전중", for: .normal)
            break

        case 2002:
            // 진행중인 충전이 없음
            self.btn_main_charge.alignTextUnderImage()
            self.btn_main_charge.tintColor = UIColor(named: "gr-8")
            self.btn_main_charge.setImage(UIImage(named: "ic_line_payment")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.btn_main_charge.setTitle("간편 충전", for: .normal)
            break
            
        default:
            break
        }
    }
}
